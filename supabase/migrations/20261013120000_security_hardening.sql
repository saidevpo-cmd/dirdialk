-- =====================================================================
-- DIALI — SECURITY HARDENING
-- =====================================================================
-- Additive migration. Applied after:
--   20261008000000_initial_schema.sql
--   20261008120000_templates_and_settings.sql
--   20261008130000_storage.sql
--
-- Goals:
--   1. Never leave a signed-in user without a profile row (least privilege
--      'viewer' by default) while keeping the app single-business.
--   2. Validate `place_order` input instead of trusting the client, and
--      restrict EXECUTE to anon/authenticated only.
--   3. Bound anonymous form submission payloads to limit spam/DoS.
--   4. Harden mutable-function grants so nothing is callable by default.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. PROFILES — auto-provision on new auth.users
-- ---------------------------------------------------------------------
-- The app reads the role from public.profiles. A user created via the
-- Supabase dashboard (or a manual insert) has no profile row, which leaves
-- them unable to read or write anything. This trigger creates a profile
-- with the LOWEST role ('viewer' = read-only). Roles are promoted by an
-- owner/admin, never by the user.
--
-- SECURITY NOTE: because `profiles.role = 'viewer'` is granted read access to
-- business data, public sign-ups MUST stay disabled
-- (Authentication → Providers → Email → Disable sign ups). With sign-ups
-- disabled only owner/staff accounts exist, so this trigger is safe.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email, ''),
    'viewer'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Helper functions are SECURITY DEFINER; they must not be invokable by
-- unrelated roles. RLS evaluation runs as the querying role, so anon and
-- authenticated keep EXECUTE; everything else is revoked.
REVOKE ALL ON FUNCTION public.current_user_role() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.has_profile() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.is_admin() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.is_staff() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.current_user_role() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.has_profile() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.is_staff() TO anon, authenticated;

-- The trigger function is never invoked directly.
REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC;

-- ---------------------------------------------------------------------
-- 2. FORM SUBMISSIONS — bound payload size (spam / DoS)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enforce_submission_size()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF octet_length(NEW.payload::text) > 262144 THEN -- 256 KiB
    RAISE EXCEPTION 'form submission payload exceeds 256 KiB';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_enforce_submission_size ON public.form_submissions;
CREATE TRIGGER trg_enforce_submission_size
  BEFORE INSERT ON public.form_submissions
  FOR EACH ROW EXECUTE FUNCTION public.enforce_submission_size();

REVOKE ALL ON FUNCTION public.enforce_submission_size() FROM PUBLIC;

-- ---------------------------------------------------------------------
-- 3. place_order — server-side validation + explicit EXECUTE grant
-- ---------------------------------------------------------------------
-- The original function is SECURITY DEFINER (it bypasses RLS to write the
-- order atomically). It must therefore validate its own input rather than
-- trusting the Flutter client to send sane numbers.
CREATE OR REPLACE FUNCTION public.place_order(
  p_order jsonb,
  p_items jsonb
) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_order_id uuid;
  v_item jsonb;
  v_qty int;
  v_number text;
BEGIN
  IF NOT public.is_staff() THEN
    RAISE EXCEPTION 'not authorized to place orders';
  END IF;

  v_number := NULLIF(btrim(p_order->>'order_number'), '');
  IF v_number IS NULL THEN
    RAISE EXCEPTION 'order_number is required';
  END IF;

  IF p_items IS NULL
     OR jsonb_typeof(p_items) <> 'array'
     OR jsonb_array_length(p_items) = 0 THEN
    RAISE EXCEPTION 'an order requires at least one item';
  END IF;

  IF COALESCE((p_order->>'subtotal')::numeric, 0) < 0
     OR COALESCE((p_order->>'discount')::numeric, 0) < 0
     OR COALESCE((p_order->>'tax')::numeric, 0) < 0
     OR COALESCE((p_order->>'shipping_fee')::numeric, 0) < 0
     OR COALESCE((p_order->>'total')::numeric, 0) < 0 THEN
    RAISE EXCEPTION 'order amounts must be non-negative';
  END IF;

  INSERT INTO public.orders (
    order_number, customer_id, status, subtotal, discount, tax, shipping_fee,
    total, customer_name, customer_email, shipping_address, shipping_city, notes
  ) VALUES (
    v_number,
    NULLIF(p_order->>'customer_id','')::uuid,
    COALESCE((p_order->>'status')::order_status, 'pending'),
    COALESCE((p_order->>'subtotal')::numeric, 0),
    COALESCE((p_order->>'discount')::numeric, 0),
    COALESCE((p_order->>'tax')::numeric, 0),
    COALESCE((p_order->>'shipping_fee')::numeric, 0),
    COALESCE((p_order->>'total')::numeric, 0),
    p_order->>'customer_name',
    p_order->>'customer_email',
    p_order->>'shipping_address',
    p_order->>'shipping_city',
    p_order->>'notes'
  ) RETURNING id INTO v_order_id;

  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
    v_qty := COALESCE((v_item->>'qty')::int, 0);
    IF v_qty <= 0 THEN
      RAISE EXCEPTION 'order item quantity must be greater than zero';
    END IF;
    IF COALESCE((v_item->>'unit_price')::numeric, 0) < 0
       OR COALESCE((v_item->>'subtotal')::numeric, 0) < 0 THEN
      RAISE EXCEPTION 'order item money must be non-negative';
    END IF;
    IF NULLIF(btrim(v_item->>'product_name'), '') IS NULL THEN
      RAISE EXCEPTION 'order item product_name is required';
    END IF;

    INSERT INTO public.order_items (
      order_id, product_id, product_name, product_sku, unit_price, qty, subtotal
    ) VALUES (
      v_order_id,
      NULLIF(v_item->>'product_id','')::uuid,
      v_item->>'product_name',
      v_item->>'product_sku',
      COALESCE((v_item->>'unit_price')::numeric, 0),
      v_qty,
      COALESCE((v_item->>'subtotal')::numeric, 0)
    );

    IF NULLIF(v_item->>'product_id', '') IS NOT NULL THEN
      -- The stock-movement trigger applies the delta and rejects negative
      -- resulting stock atomically.
      INSERT INTO public.stock_movements (product_id, delta, reason, reference)
      VALUES (
        (v_item->>'product_id')::uuid,
        -v_qty,
        'order',
        v_number
      );
    END IF;
  END LOOP;

  RETURN v_order_id;
END;
$$;

REVOKE ALL ON FUNCTION public.place_order(jsonb, jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.place_order(jsonb, jsonb) TO authenticated;

-- ---------------------------------------------------------------------
-- 4. Grant hygiene for the remaining privileged functions
-- ---------------------------------------------------------------------
-- `apply_stock_movement`, `increment_form_submissions` and
-- `handle_updated_at` are triggers and must never be called via RPC.
REVOKE ALL ON FUNCTION public.apply_stock_movement() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.increment_form_submissions() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.handle_updated_at() FROM PUBLIC;
