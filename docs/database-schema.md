# diali — Database Schema

> Single-business (no multi-tenancy). PostgreSQL via Supabase.
> Migrations live in `supabase/migrations/`. Seed in `supabase/seed.sql`.

## Migration files

| File | Contents |
|---|---|
| `20261008000000_initial_schema.sql` | Enums, 15 tables, indexes, helper functions, triggers, `place_order` RPC, RLS for core tables. |
| `20261008120000_templates_and_settings.sql` | `website_templates`, `site_settings`, `app_settings` + RLS. |
| `20261008130000_storage.sql` | Storage buckets + object policies. |
| `20261013120000_security_hardening.sql` | Profile auto-provisioning, `place_order` validation, form-payload size limit, function grants. |
| `20261013130000_least_privilege_and_storage.sql` | `profiles.role` defaults to `viewer`, `resources` bucket MIME allow-list. |
| `20261013140000_owner_only_roles_and_execute_hardening.sql` | `is_owner()`, owner-only role-change trigger, revoke `place_order` from `anon`. |
| `20261015120000_checkout_integrity_social_and_location.sql` | `orders.customer_phone` + `idempotency_key`, `site_settings` social links + coordinates, updated `place_order()` (server-side pricing + stock pre-check), `apply_order_status_stock()` trigger. |
| `20261017120000_order_tracking.sql` | Public `track_order(order_number, phone)` RPC + `order_tracking_attempts` throttle ledger. |
| `../seed.sql` | Default templates, site settings, app settings. |

> Migrations are additive and applied in filename order. Never edit an applied
> migration; add a new timestamped one instead.

## Tables

### `profiles`
Maps `auth.users` → role. `id uuid PK → auth.users(id)`, `full_name`, `avatar_url`,
`role user_role` (`owner|admin|staff|viewer`, default `viewer`; promoted to `owner`
only by the SQL editor/`service_role` during bootstrap), timestamps.

### `locations`
`id`, `name`, `type location_type` (`warehouse|store|office|customer|shipping|other`),
`address`, `city`, `country`, `latitude`, `longitude`, `contact_person`, `contact_phone`,
`is_default`, timestamps.

### `categories` (product)
`id`, `name`, `slug UNIQUE`, `description`, `parent_id → categories`, `position`, `image_url`, timestamps.

### `products`
`id`, `name`, `description`, `sku UNIQUE`, `category_id → categories (set null)`,
`location_id → locations (set null)`, `tracking_status text` (Dart `TrackingStatus.name`),
`tracking_code`, `price numeric(12,2) >= 0`, `cost_price`, `stock_qty int >= 0`,
`low_stock_threshold`, `unit`, `image_url`, `extra_images jsonb`, `is_demo`, `status product_status`,
timestamps. Check constraints guard prices/stock.

### `product_images`
`id`, `product_id → products (cascade)`, `url NOT NULL`, `alt`, `position`, `created_at`.

### `stock_movements` (append-only ledger)
`id`, `product_id → products (cascade)`, `delta int <> 0`, `resulting_qty`, `reason`, `reference`,
`actor_name`, `created_at`. A `BEFORE INSERT` trigger applies `delta` to `products.stock_qty`
and rejects movements that would drive stock negative — inventory can never desync.

### `tracking_events`
`id`, `product_id → products (cascade)`, `status text`, `status_title`, `location_id → locations`,
`location_name`, `location_address`, `latitude`, `longitude`, `actor_name`, `actor_role`,
`description`, `reference_number`, `notes`, `occurred_at`, `created_at`.

### `customers`
`id`, `name`, `email UNIQUE`, `phone`, `address`, `city`, `country`, `tier customer_tier`,
`notes`, `total_orders`, `total_spent numeric(12,2)`, timestamps.

### `orders`
`id`, `order_number UNIQUE`, `customer_id → customers (set null)`, `status order_status`,
`subtotal`, `discount`, `tax`, `shipping_fee`, `total` (all `>= 0`), customer snapshot fields
(`customer_name`, `customer_email`, `customer_phone` — the phone is the public-tracking
proof of ownership, digits compared, `shipping_address`, `shipping_city`, `notes`),
`idempotency_key UNIQUE` (client retry guard), `paid_at`, `delivered_at`, `cancelled_at`,
timestamps.

### `order_items`
`id`, `order_id → orders (cascade)`, `product_id → products (set null)`, `product_name` (snapshot),
`product_sku`, `unit_price >= 0`, `qty > 0`, `subtotal >= 0`, `created_at`.

### `page_categories` (article categories)
`id`, `name`, `slug UNIQUE`, `description`, timestamps.

### `pages` (articles + static pages)
`id`, `title`, `slug UNIQUE`, `excerpt`, `content`, `image_url`, `category_id → page_categories`,
`status page_status`, `meta_title`, `meta_desc`, `published_at`, timestamps.

### `resources`
`id`, `name`, `description`, `type resource_type`, `category`, `url`, `contact`, `location`,
`image_url`, `is_published`, `storage_path`, `storage_size`, `mime_type`, `folder_id → resources`,
timestamps.

### `form_definitions` / `form_submissions`
As modeled by the app; `fields jsonb`, `submissions_count` incremented by trigger; submissions hold
`payload jsonb`.

### `website_templates`
`id`, `name`, `slug UNIQUE`, `description`, `category text`,
`preview_image_url`, `tags jsonb`, `is_published`, `is_featured`, `customization jsonb`, timestamps.
`customization` mirrors `TemplateCustomization` so presentation can evolve without migrations.

### `site_settings` (single row)
`active_template_id → website_templates`, brand fields, color hexes, hero content, contact info,
section toggles (`show_hero`, `show_featured_products`, `show_articles`, `show_contact`),
`latitude`/`longitude` (business location, range-checked), and `social_links jsonb`
(`{ "instagram": {"url": "https://..."}, ... }` — validated by
`is_valid_social_links()` for known platforms and http(s) URLs only).

### `app_settings` (key/value)
`key text PK`, `value jsonb` — `currency` (`{code,symbol}`), `tax_rate` (`{percent}`),
`default_locale`.

### `order_tracking_attempts` (private throttle ledger)
`id bigint identity PK`, `caller text` (md5 of the caller IP, or `order:<md5(order_number)>`
when request headers are absent), `attempted_at timestamptz`. RLS is enabled with **no
policies** and all privileges are revoked from `anon`/`authenticated`; only the
`SECURITY DEFINER` `track_order()` function touches it. Used to rate-limit anonymous
tracking lookups (20 per 10-minute sliding window) and pruned opportunistically.

## Relationships

```
categories ──1:N── products ──1:N── product_images
locations  ──1:N── products
products   ──1:N── stock_movements
products   ──1:N── tracking_events ──N:1── locations
customers  ──1:N── orders ──1:N── order_items ──N:1── products
page_categories ──1:N── pages
website_templates ──1:1── site_settings.active_template_id
form_definitions ──1:N── form_submissions
resources (self-referential folder_id)
```

## Functions & triggers

- `handle_updated_at()` — `updated_at` on every mutable table.
- `apply_stock_movement()` — atomic stock consistency + negative-stock guard.
- `increment_form_submissions()` — submissions counter.
- `place_order(p_order jsonb, p_items jsonb)` — **atomic** order + items + stock movements in one
  transaction; call via `supabase.rpc('place_order', ...)`. Recomputes money server-side and rejects
  insufficient stock; supports idempotent retries via `idempotency_key`.
- `apply_order_status_stock()` — releases stock when an order is cancelled/deleted and re-reserves it
  when a cancelled order is reopened.
- `track_order(p_order_number text, p_phone text)` — `SECURITY DEFINER` public RPC (search path pinned
  to `public, pg_temp`, `EXECUTE` granted to `anon`/`authenticated`). Requires **both** the order
  number and the checkout phone, returns a PII-free JSON projection (or `NULL` for an unknown
  order / wrong phone alike), validates inputs and throttles anonymous callers. See
  `security-review.md` §3.1.
- `enforce_profile_role_change()` — `BEFORE UPDATE` trigger guard: role changes are owner-only for the
  client roles, while `postgres`/`service_role` can bootstrap/repair.
- `current_user_role()`, `has_profile()`, `is_admin()`, `is_staff()`, `is_owner()` — `SECURITY DEFINER`
  helpers used by RLS to avoid recursion on `profiles`.

## Pagination, filtering, search

All list queries use `.range(offset, offset+limit-1)` with server-side `.ilike`, `.eq`, `.order`.
Default limits mirror `PaginatedResult` (products/orders/customers 20, resources 30).

## Applying the schema

```bash
# Option A — Supabase CLI linked to a project
supabase db push

# Option B — SQL editor: run migrations in filename order, then seed.sql
```
