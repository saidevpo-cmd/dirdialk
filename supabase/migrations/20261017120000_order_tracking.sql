-- =====================================================================
-- DIALI — public order tracking
--
-- Adds a single, deliberately narrow, SECURITY DEFINER RPC that lets a
-- customer look up **their own** order from the public storefront without
-- exposing the private `orders` / `order_items` tables (which stay under
-- staff-only RLS).
--
-- Threat model / decisions:
--   * `orders` has no anon read policy and never will. Tracking therefore
--     goes through `track_order()`, which runs as the owner and returns a
--     curated, allow-listed JSON document — never the raw row.
--   * A lookup requires BOTH the order number and the checkout phone
--     number. The phone is the proof-of-ownership factor; a bare order
--     number is not enough.
--   * A missing order and a wrong phone return the same `NULL`, so the
--     endpoint cannot be used as an order-number oracle.
--   * Anonymous abuse (scripted guessing) is throttled per caller. The
--     caller identity is the client IP from the PostgREST request headers
--     (`x-forwarded-for`), hashed with `md5` so raw IPs are not stored;
--     when headers are unavailable we fall back to a bucket derived from
--     the order number. IP-based edge rate limiting / CAPTCHA is still
--     recommended for a public deployment — see docs/security-review.md.
--
-- Nothing here edits an applied migration.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Throttle ledger
--
-- This table is an implementation detail of track_order(). It must never
-- be readable or writable by anon/authenticated: RLS is enabled with NO
-- policies (default deny) and all table privileges are revoked. Only the
-- SECURITY DEFINER function (runs as the table owner) touches it.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.order_tracking_attempts (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  -- md5 hex of the caller IP, or 'order:<md5(order_number)>' fallback.
  caller       text NOT NULL,
  attempted_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.order_tracking_attempts ENABLE ROW LEVEL SECURITY;

-- Supabase grants ALL on new public tables to anon/authenticated by
-- default; revoke explicitly so the table is owner-only even if a future
-- migration changes RLS.
REVOKE ALL ON TABLE public.order_tracking_attempts FROM PUBLIC;
REVOKE ALL ON TABLE public.order_tracking_attempts FROM anon, authenticated;

-- Supports the "attempts by this caller in the last window" count and the
-- periodic prune.
CREATE INDEX IF NOT EXISTS idx_tracking_attempts_caller
  ON public.order_tracking_attempts (caller, attempted_at DESC);
CREATE INDEX IF NOT EXISTS idx_tracking_attempts_time
  ON public.order_tracking_attempts (attempted_at);

-- ---------------------------------------------------------------------
-- 2. track_order(order_number, phone)
--
-- SECURITY DEFINER: bypasses RLS to read the private order, but validates
-- its own inputs and returns only an allow-listed projection. The search
-- path is pinned (public, pg_temp) to stop search_path hijacking.
--
-- Returns a JSON object on success, or NULL when no order matches the
-- (order_number, phone) pair. Raises on invalid input or when throttled.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.track_order(
  p_order_number text,
  p_phone        text
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_number     text;
  v_digits     text;
  v_headers    text;
  v_ip         text;
  v_caller     text;
  v_recent     int;
  v_order      public.orders%ROWTYPE;
  v_items      jsonb;
  v_currency   text := '';
  -- Sliding window and per-caller allowance for anonymous lookups.
  c_window     constant interval := interval '10 minutes';
  c_max        constant int := 20;
BEGIN
  -- ---- input validation (never trust the caller) ------------------
  v_number := upper(btrim(COALESCE(p_order_number, '')));
  IF v_number = '' OR char_length(v_number) > 64 THEN
    RAISE EXCEPTION 'a valid order number is required';
  END IF;

  v_digits := regexp_replace(COALESCE(p_phone, ''), '\D', '', 'g');
  -- Mirrors PhoneNumber.isValid() / place_order(): 7-15 digits.
  IF length(v_digits) < 7 OR length(v_digits) > 15 THEN
    RAISE EXCEPTION 'a valid phone number is required';
  END IF;

  -- ---- identify the caller for throttling -------------------------
  -- PostgREST exposes request headers via current_setting; the value may
  -- be absent (e.g. direct SQL calls) — fall back to the order number.
  BEGIN
    v_headers := current_setting('request.headers', true);
    IF v_headers IS NOT NULL AND v_headers <> '' THEN
      v_ip := (v_headers::jsonb) ->> 'x-forwarded-for';
      IF v_ip IS NOT NULL AND v_ip <> '' THEN
        -- x-forwarded-for may be "client, proxy1, ..."; take the first.
        v_caller := 'ip:' || md5(btrim(split_part(v_ip, ',', 1)));
      END IF;
    END IF;
  EXCEPTION WHEN others THEN
    -- A malformed header must never break a legitimate lookup.
    v_caller := NULL;
  END;

  v_caller := COALESCE(v_caller, 'order:' || md5(v_number));

  -- ---- throttle ---------------------------------------------------
  SELECT count(*) INTO v_recent
    FROM public.order_tracking_attempts
   WHERE caller = v_caller
     AND attempted_at > now() - c_window;

  IF v_recent >= c_max THEN
    RAISE EXCEPTION 'too many tracking attempts, please try again later';
  END IF;

  INSERT INTO public.order_tracking_attempts (caller) VALUES (v_caller);

  -- Opportunistic prune keeps the ledger bounded without a scheduled job.
  IF random() < 0.02 THEN
    DELETE FROM public.order_tracking_attempts
     WHERE attempted_at < now() - interval '1 day';
  END IF;

  -- ---- lookup -----------------------------------------------------
  -- Case-insensitive on the (human) order number; phone compared on
  -- digits only so "+212 600-000-000" and "212600000000" match. Both
  -- factors are required, and the same NULL is returned whether the
  -- number is unknown or the phone is wrong (no enumeration oracle).
  SELECT * INTO v_order
    FROM public.orders
   WHERE upper(order_number) = v_number
     AND regexp_replace(COALESCE(customer_phone, ''), '\D', '', 'g') = v_digits
   LIMIT 1;

  IF NOT FOUND THEN
    RETURN NULL;
  END IF;

  -- ---- curated projection (allow-list, no PII) --------------------
  SELECT COALESCE(
           jsonb_agg(
             jsonb_build_object(
               'name',     product_name,
               'qty',      qty,
               'subtotal', subtotal
             )
             ORDER BY product_name
           ),
           '[]'::jsonb
         )
    INTO v_items
    FROM public.order_items
   WHERE order_id = v_order.id;

  SELECT COALESCE(value ->> 'symbol', '')
    INTO v_currency
    FROM public.app_settings
   WHERE key = 'currency';

  RETURN jsonb_build_object(
    'order_number',   v_order.order_number,
    'status',         v_order.status,
    'created_at',     v_order.created_at,
    'updated_at',     v_order.updated_at,
    'paid_at',        v_order.paid_at,
    'delivered_at',   v_order.delivered_at,
    'cancelled_at',   v_order.cancelled_at,
    'total',          v_order.total,
    'currency_symbol', COALESCE(v_currency, ''),
    'items',          v_items
  );
END;
$$;

-- Anonymous storefront visitors must be able to call this; nothing else
-- is exposed. The helper functions used above are already granted.
REVOKE ALL ON FUNCTION public.track_order(text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.track_order(text, text) TO anon, authenticated;
