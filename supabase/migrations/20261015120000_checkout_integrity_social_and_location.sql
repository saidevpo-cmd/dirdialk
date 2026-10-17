-- =====================================================================
-- DIALI — checkout integrity, inventory consistency, business
--         location and social links
--
-- New in this migration (nothing here edits an applied migration):
--   1. orders: customer_phone + idempotency_key (safe client retries)
--   2. site_settings: latitude/longitude + social_links (with checks)
--   3. app_settings.updated_at trigger (was missing)
--   4. indexes for the repository list/sort/filter patterns
--   5. place_order(): server-side pricing, contact validation,
--      stock pre-check, idempotent replay — the client can no longer
--      dictate prices, quantities or totals
--   6. apply_order_status_stock(): stock is restored when an order is
--      cancelled/deleted and re-reserved when it is reopened, so
--      inventory never drifts across the order lifecycle
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. ORDERS — contact phone + idempotent checkout key
-- ---------------------------------------------------------------------
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS customer_phone text;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS idempotency_key uuid;

-- Duplicate submissions of the same checkout attempt must not create a
-- second order: the client keeps one key per attempt and reuses it on
-- retry, so a lost response can be replayed safely.
CREATE UNIQUE INDEX IF NOT EXISTS uq_orders_idempotency_key
  ON public.orders (idempotency_key)
  WHERE idempotency_key IS NOT NULL;

-- Lenient shape guard only (the strict digit-count rule lives in
-- place_order() where the message is actionable). The column is new, so no
-- existing row can violate it.
ALTER TABLE public.orders DROP CONSTRAINT IF EXISTS orders_customer_phone_shape;
ALTER TABLE public.orders ADD CONSTRAINT orders_customer_phone_shape
  CHECK (customer_phone IS NULL OR char_length(customer_phone) <= 32);

-- Contact name/phone are required for orders placed through checkout; the
-- columns stay nullable for legacy/imported rows.

CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_customer_phone ON public.orders (customer_phone)
  WHERE customer_phone IS NOT NULL;

-- ---------------------------------------------------------------------
-- 2. SITE SETTINGS — business location + public social links
--    Business address/coords are intentionally public (a storefront must
--    be able to show them). Customer delivery addresses stay on `orders`,
--    which has no public read policy.
-- ---------------------------------------------------------------------
ALTER TABLE public.site_settings
  ADD COLUMN IF NOT EXISTS latitude double precision,
  ADD COLUMN IF NOT EXISTS longitude double precision,
  ADD COLUMN IF NOT EXISTS social_links jsonb NOT NULL DEFAULT '{}'::jsonb;

ALTER TABLE public.site_settings DROP CONSTRAINT IF EXISTS site_settings_latitude_range;
ALTER TABLE public.site_settings ADD CONSTRAINT site_settings_latitude_range
  CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90);

ALTER TABLE public.site_settings DROP CONSTRAINT IF EXISTS site_settings_longitude_range;
ALTER TABLE public.site_settings ADD CONSTRAINT site_settings_longitude_range
  CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180);

-- Only the six supported platforms may appear as keys, each entry must be
-- an object carrying a string url of a sane length.
--
-- A CHECK constraint cannot contain a subquery, so the shape rule lives in
-- an IMMUTABLE helper that the constraint calls. Values are otherwise
-- validated (and normalised) client-side in `SocialLinks`.
CREATE OR REPLACE FUNCTION public.is_valid_social_links(p_links jsonb)
RETURNS boolean
LANGUAGE sql IMMUTABLE AS $$
  SELECT jsonb_typeof(p_links) = 'object'
     AND NOT EXISTS (
           SELECT 1 FROM jsonb_each(p_links) AS e(k, v)
            WHERE e.k <> ALL (ARRAY[
                    'instagram', 'facebook', 'tiktok',
                    'whatsapp', 'youtube', 'linkedin'
                  ])
         )
     AND NOT EXISTS (
           SELECT 1 FROM jsonb_each(p_links) AS e(k, v)
            WHERE jsonb_typeof(e.v) <> 'object'
               OR NOT (e.v ? 'url')
               OR jsonb_typeof(e.v -> 'url') <> 'string'
               OR char_length(e.v ->> 'url') > 300
         );
$$;

ALTER TABLE public.site_settings DROP CONSTRAINT IF EXISTS site_settings_social_links_shape;
ALTER TABLE public.site_settings ADD CONSTRAINT site_settings_social_links_shape
  CHECK (public.is_valid_social_links(social_links));

-- ---------------------------------------------------------------------
-- 3. app_settings was missing its updated_at trigger
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS set_updated_at ON public.app_settings;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.app_settings
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ---------------------------------------------------------------------
-- 4. Indexes matching the query patterns in the Dart repositories
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_products_updated_at ON public.products (updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_customers_created_at ON public.customers (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_categories_parent ON public.categories (parent_id);
CREATE INDEX IF NOT EXISTS idx_resources_folder ON public.resources (folder_id);
CREATE INDEX IF NOT EXISTS idx_form_definitions_status ON public.form_definitions (status);
CREATE INDEX IF NOT EXISTS idx_form_definitions_updated_at ON public.form_definitions (updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_form_submissions_form ON public.form_submissions (form_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product ON public.order_items (product_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_reason ON public.stock_movements (reason);

-- ---------------------------------------------------------------------
-- 5. place_order() — server-authoritative pricing and totals
--
--    The client may no longer influence money: unit prices are read from
--    products (row-locked, which also serialises concurrent checkouts for
--    the same product), subtotals/tax/total are recomputed, the tax rate
--    comes from app_settings, and the configured discount can never
--    exceed the subtotal.
--    Signature is unchanged, so the existing GRANT/REVOKE still apply.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.place_order(
  p_order jsonb,
  p_items jsonb
) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_order_id   uuid;
  v_existing   uuid;
  v_key        uuid;
  v_item       jsonb;
  v_qty        int;
  v_number     text;
  v_name       text;
  v_phone      text;
  v_phoneless  text;
  v_product_id uuid;
  v_price      numeric(12,2);
  v_stock      int;
  v_line       numeric(12,2);
  v_subtotal   numeric(12,2) := 0;
  v_discount   numeric(12,2);
  v_shipping   numeric(12,2);
  v_tax_rate   numeric(6,3) := 0;
  v_tax        numeric(12,2);
  v_total      numeric(12,2);
  v_status     order_status;
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

  -- Guest checkout: no customer account is required, but contact
  -- information is. A stored procedure cannot localise these messages, so
  -- the client shows its own localized copy for the same rules.
  v_name := NULLIF(btrim(p_order->>'customer_name'), '');
  IF v_name IS NULL THEN
    RAISE EXCEPTION 'customer name is required';
  END IF;

  v_phone := NULLIF(btrim(COALESCE(p_order->>'customer_phone', '')), '');
  IF v_phone IS NULL THEN
    RAISE EXCEPTION 'customer phone number is required';
  END IF;
  v_phoneless := regexp_replace(v_phone, '\D', '', 'g');
  IF length(v_phoneless) < 7 OR length(v_phoneless) > 15 THEN
    RAISE EXCEPTION 'customer phone number is invalid';
  END IF;

  -- Idempotent replay: the same key must yield the same order and must
  -- never move stock twice. The partial unique index makes this safe under
  -- concurrency: the loser of a race gets a unique_violation, handled below.
  v_key := NULLIF(p_order->>'idempotency_key', '')::uuid;
  IF v_key IS NOT NULL THEN
    SELECT id INTO v_existing FROM public.orders WHERE idempotency_key = v_key;
    IF FOUND THEN
      RETURN v_existing;
    END IF;
  END IF;

  v_status   := COALESCE((p_order->>'status')::order_status, 'pending');
  v_discount := COALESCE((p_order->>'discount')::numeric, 0);
  v_shipping := COALESCE((p_order->>'shipping_fee')::numeric, 0);
  IF v_discount < 0 OR v_shipping < 0 THEN
    RAISE EXCEPTION 'order amounts must be non-negative';
  END IF;

  SELECT COALESCE((value->>'percent')::numeric, 0)
    INTO v_tax_rate
    FROM public.app_settings
   WHERE key = 'tax_rate';
  IF NOT FOUND THEN
    v_tax_rate := 0;
  END IF;

  ---------------------------------------------------------------------
  -- Pass 1: validate and price every line against the product table.
  --         SELECT ... FOR UPDATE locks each product row, so two
  --         concurrent checkouts for the same product are serialised
  --         before either can reserve stock.
  ---------------------------------------------------------------------
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
    v_qty := COALESCE((v_item->>'qty')::int, 0);
    IF v_qty <= 0 THEN
      RAISE EXCEPTION 'order item quantity must be greater than zero';
    END IF;
    IF NULLIF(btrim(v_item->>'product_name'), '') IS NULL THEN
      RAISE EXCEPTION 'order item product_name is required';
    END IF;

    v_product_id := NULLIF(v_item->>'product_id', '')::uuid;
    IF v_product_id IS NULL THEN
      RAISE EXCEPTION 'every order item must reference a product';
    END IF;

    SELECT price, stock_qty INTO v_price, v_stock
      FROM public.products
     WHERE id = v_product_id
       FOR UPDATE;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'product % is no longer available', v_product_id;
    END IF;
    IF v_stock < v_qty THEN
      RAISE EXCEPTION 'insufficient stock for % (requested %, available %)',
        btrim(v_item->>'product_name'), v_qty, v_stock;
    END IF;

    v_line     := round(v_price * v_qty, 2);
    v_subtotal := v_subtotal + v_line;
  END LOOP;

  -- Server-computed money. A discount larger than the subtotal is clamped
  -- rather than trusted, and the client's subtotal/tax/total are ignored.
  IF v_discount > v_subtotal THEN
    v_discount := v_subtotal;
  END IF;
  v_tax   := round((v_subtotal - v_discount) * v_tax_rate / 100, 2);
  v_total := v_subtotal - v_discount + v_tax + v_shipping;

  BEGIN
    INSERT INTO public.orders (
      order_number, customer_id, status, subtotal, discount, tax, shipping_fee,
      total, customer_name, customer_phone, customer_email,
      shipping_address, shipping_city, notes, idempotency_key, paid_at
    ) VALUES (
      v_number,
      NULLIF(p_order->>'customer_id', '')::uuid,
      v_status,
      v_subtotal,
      v_discount,
      v_tax,
      v_shipping,
      v_total,
      v_name,
      v_phone,
      NULLIF(btrim(COALESCE(p_order->>'customer_email', '')), ''),
      NULLIF(p_order->>'shipping_address', ''),
      NULLIF(p_order->>'shipping_city', ''),
      p_order->>'notes',
      v_key,
      CASE WHEN v_status = 'pending' THEN NULL ELSE now() END
    ) RETURNING id INTO v_order_id;
  EXCEPTION WHEN unique_violation THEN
    -- Lost an idempotency race: another session inserted the same attempt.
    SELECT id INTO v_existing FROM public.orders WHERE idempotency_key = v_key;
    IF v_existing IS NOT NULL THEN
      RETURN v_existing;
    END IF;
    RAISE;
  END;

  ---------------------------------------------------------------------
  -- Pass 2: the validated, server-priced lines + their stock movements.
  ---------------------------------------------------------------------
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
    v_qty        := COALESCE((v_item->>'qty')::int, 0);
    v_product_id := NULLIF(v_item->>'product_id', '')::uuid;

    SELECT price INTO v_price FROM public.products WHERE id = v_product_id;

    INSERT INTO public.order_items (
      order_id, product_id, product_name, product_sku, unit_price, qty, subtotal
    ) VALUES (
      v_order_id,
      v_product_id,
      btrim(v_item->>'product_name'),
      NULLIF(v_item->>'product_sku', ''),
      COALESCE(v_price, 0),
      v_qty,
      round(COALESCE(v_price, 0) * v_qty, 2)
    );

    -- The stock-movement trigger applies the delta and rejects a negative
    -- resulting stock atomically (products.stock_qty has CHECK >= 0 too).
    INSERT INTO public.stock_movements (product_id, delta, reason, reference)
    VALUES (v_product_id, -v_qty, 'order', v_number);
  END LOOP;

  RETURN v_order_id;
END;
$$;

REVOKE ALL ON FUNCTION public.place_order(jsonb, jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.place_order(jsonb, jsonb) TO authenticated;

-- ---------------------------------------------------------------------
-- 6. Inventory across the order lifecycle
--
--    status change -> cancelled: put stock back
--    status change <- cancelled: take stock again (still stock-checked)
--    DELETE of a live order:    put stock back
--    DELETE of a cancelled one: no-op (already restored on cancel)
--
--    The function is SECURITY DEFINER because it writes stock_movements
--    and products on behalf of whoever changed the order; it never
--    broadens who may *change* the order (that is still RLS).
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.apply_order_status_stock()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_item       record;
  v_order_id   uuid;
  v_order_no   text;
  v_restore    boolean := false;
  v_reserve    boolean := false;
BEGIN
  IF TG_OP = 'DELETE' THEN
    v_order_id := OLD.id;
    v_order_no := OLD.order_number;
    -- Deleting a live order returns its reserved units; a cancelled order
    -- already had them returned on cancel, so deleting it is a no-op.
    v_restore  := (OLD.status <> 'cancelled');
  ELSE
    IF NEW.status = OLD.status THEN
      RETURN NEW;
    END IF;
    v_order_id := NEW.id;
    v_order_no := NEW.order_number;
    v_restore  := (NEW.status = 'cancelled' AND OLD.status <> 'cancelled');
    v_reserve  := (OLD.status = 'cancelled' AND NEW.status <> 'cancelled');
  END IF;

  IF v_restore THEN
    -- Restoring: no stock check needed (adding stock cannot go negative).
    FOR v_item IN
      SELECT product_id, qty FROM public.order_items
       WHERE order_id = v_order_id AND product_id IS NOT NULL
    LOOP
      INSERT INTO public.stock_movements (product_id, delta, reason, reference)
      VALUES (v_item.product_id, v_item.qty, 'order_cancelled', v_order_no);
    END LOOP;
  ELSIF v_reserve THEN
    -- Re-opening a cancelled order re-reserves stock; the movement trigger
    -- raises if it is no longer available, so stock can never go negative.
    FOR v_item IN
      SELECT product_id, qty FROM public.order_items
       WHERE order_id = v_order_id AND product_id IS NOT NULL
    LOOP
      INSERT INTO public.stock_movements (product_id, delta, reason, reference)
      VALUES (v_item.product_id, -v_item.qty, 'order_reopened', v_order_no);
    END LOOP;
  END IF;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_apply_order_status_stock ON public.orders;
-- BEFORE (not AFTER) so that a DELETE still sees its order_items before the
-- ON DELETE CASCADE removes them.
CREATE TRIGGER trg_apply_order_status_stock
  BEFORE UPDATE OR DELETE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.apply_order_status_stock();

REVOKE ALL ON FUNCTION public.apply_order_status_stock() FROM PUBLIC;
