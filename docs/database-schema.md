# diali — Database Schema

> Single-business (no multi-tenancy). PostgreSQL via Supabase.
> Migrations live in `supabase/migrations/`. Seed in `supabase/seed.sql`.

## Migration files

| File | Contents |
|---|---|
| `20261008000000_initial_schema.sql` | Enums, 15 tables, indexes, helper functions, triggers, `place_order` RPC, RLS for core tables. |
| `20261008120000_templates_and_settings.sql` | `website_templates`, `site_settings`, `app_settings` + RLS. |
| `20261008130000_storage.sql` | Storage buckets + object policies. |
| `../seed.sql` | Default templates, site settings, app settings. |

## Tables

### `profiles`
Maps `auth.users` → role. `id uuid PK → auth.users(id)`, `full_name`, `avatar_url`,
`role user_role` (`owner|admin|staff|viewer`, default `owner`), timestamps.

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
`subtotal`, `discount`, `tax`, `shipping_fee`, `total` (all `>= 0`), customer snapshot fields,
`paid_at`, `delivered_at`, `cancelled_at`, timestamps.

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
section toggles (`show_hero`, `show_featured_products`, `show_articles`, `show_contact`).

### `app_settings` (key/value)
`key text PK`, `value jsonb` — `currency`, `tax_rate`, `default_locale`.

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
  transaction; call via `supabase.rpc('place_order', ...)`.
- `current_user_role()`, `has_profile()`, `is_admin()`, `is_staff()` — `SECURITY DEFINER` helpers used
  by RLS to avoid recursion on `profiles`.

## Pagination, filtering, search

All list queries use `.range(offset, offset+limit-1)` with server-side `.ilike`, `.eq`, `.order`.
Default limits mirror `PaginatedResult` (products/orders/customers 20, resources 30).

## Applying the schema

```bash
# Option A — Supabase CLI linked to a project
supabase db push

# Option B — SQL editor: run migrations in filename order, then seed.sql
```
