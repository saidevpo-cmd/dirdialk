# Diali — Business Management Platform

A Flutter application providing a complete multilingual business management dashboard:
Dashboard, Products, Categories, Orders, Customers, Resources, Forms, Pages and a built-in Storefront.

**Supports Arabic / English / Français with full RTL↔LTR switching.**

---

## Features

### Admin Dashboard
- Stat cards: products, categories, orders, customers
- Quick-action panel (add product, new order, add customer, add resource)
- Recent orders, recent products, latest articles, resource directory panels
- All panels navigate to the corresponding section

### Products
- Full CRUD with image manager (multi-image gallery, main image, reorder, crop)
- Filters: by category, by status (active / draft / archived)
- Full-text search by name or SKU
- Stat cards: total, active, low-stock, out-of-stock
- Product details page with image gallery
- Responsive desktop table + mobile card layout

### Categories
- Full CRUD with image field
- Category image gallery cards (click to view products in category)
- Slug auto-generation from name
- Reassigns products to "Uncategorized" before category deletion

### Orders
- Full status lifecycle: pending → paid → shipped → delivered / cancelled
- Detail dialog with customer info, order items, totals
- Status update actions within the dialog
- Pagination (10 per page), search, status filter
- Stat cards: total, revenue, pending, delivered

### Customers
- Full CRUD: name, email, phone, city, country, address, tier (regular/VIP), notes
- VIP badge and spent amount tracking
- Search and tier filter

### Resources (File Directory)
- Create, edit, delete resource entries (document, spreadsheet, image, folder, other)
- Filter by type, category, publish status
- Client-side search across name, description, URL, tags

### Forms
- Form definitions with full CRUD
- Status lifecycle (draft / published / archived)
- Field definitions with types and configuration

### Pages / Articles
- Page content with status workflow (draft / published)
- Search and status filter

### Storefront
- Category carousel, product grid
- Add to cart, quantity control, checkout with validation
- Server-side order placement via `place_order()` PostgreSQL function
- Idempotent checkout (safe retries without duplicate orders)
- Stock pre-check + server-side pricing (client cannot dictate prices)
- Public order tracking (`/track`) by order number + checkout phone, backed by the
  `track_order()` RPC (no access to the private orders tables)
- Footer with business contact details, social links and a WhatsApp chat button
  (configured in Settings)

### Settings
- Language: Arabic / English / Français
- Appearance: Light / Dark / System
- Style: Modern / Minimal / Professional
- Notifications: orders, low stock, weekly digest toggles
- Privacy: analytics, crash reporting, personalization
- Consent management with privacy policy and terms of service dialogs
- Social links editor for the public storefront (Instagram, Facebook, TikTok,
  WhatsApp, YouTube, LinkedIn)
- Data export (preferences JSON), demo data loader, reset
- Account section (sign out) when backend is configured

---

## Architecture

```text
lib/
  main.dart                 # entry point — Supabase, Hive, auth, repositories
  app/
    app.dart                # MaterialApp.router with locale, theme, auth
    router.dart             # GoRouter: /login, /admin/<section>
  core/
    auth/                   # AuthController + SupabaseAuthGateway
    config/                 # AppConfig (--dart-define compile-time env)
    design_system/          # AppColors, Palette, Typography, Spacing, Theme, Style
    images/                 # ImageStore, ImageService, AppImage, HiveImageStore
    navigation/             # NavSection enum + routing metadata
    settings/               # SettingsController (all persisted preferences)
    storage/                # CatalogStore, HiveCatalogStore, HiveSettingsStore
    supabase/               # AppSupabase init, SupabaseResult (guard/Success/Failure)
    cart/                   # CartController + CartScope (storefront)
  domain/
    models/                 # Product, Category, Order, Customer, Resource, etc.
    repositories/           # Repository interfaces (ProductRepository, etc.)
  data/
    app_repositories.dart   # Composition root: switches mock ↔ Supabase
    mock/                   # In-memory + Hive repositories (offline/test)
    supabase/               # Supabase-backed repositories (production)
    demo/                   # Demo catalog + repeat-safe seeder
  features/
    auth/                   # LoginPage (email + password)
    shell/                  # Responsive app shell: sidebar/rail/drawer
    dashboard/              # Dashboard with live stats and recent activity
    products/               # Products list, details page, image manager/gallery
    categories/             # Categories list, image field, product preview
    orders/                 # Orders list, pagination, detail dialog
    customers/              # Customers list, CRUD dialog
    resources/              # Resources directory list, CRUD dialog
    forms/                  # Form definitions list, CRUD dialog
    pages/                  # Page content list, CRUD dialog
    store/                  # Storefront with cart and checkout
    tracking/               # Public order tracking (/track)
    settings/               # All settings sections
  shared/
    utils/                  # AppFeedback, DialogSizing, IdGen, PhoneNumber
    widgets/                # AppCard, AppImage, EmptyStateView, ErrorStateView,
                            # PaginationBar, ResponsiveDataTable, SearchAndFilterBar,
                            # StatCard, StatusBadge, ImagePlaceholder
  l10n/
    generated/              # Generated AppLocalizations (ar, en, fr)
assets/
  images/                   # Bundled demo images (products/categories/banners)
  fonts/                    # Inter (Latin) + Cairo (Arabic)
supabase/
  migrations/               # 8 sequential SQL migrations
  seed.sql                  # Optional demo seed data
docs/
  deployment-guide.md       # Production deployment steps
```

---

## Backend (Supabase)

The app runs in two modes, selected at compile time:

| Mode | Trigger | Repositories | Auth |
|------|---------|--------------|------|
| Local / offline | No `--dart-define` | Mock + Hive | None required |
| Production | `SUPABASE_URL` + `SUPABASE_ANON_KEY` provided | Supabase | Email + password |

### Database schema (8 migrations applied in order)

1. `20261008000000_initial_schema.sql` — core tables: profiles, locations, categories, products, product_images, stock_movements, tracking_events, orders, order_items, customers, resources, form_definitions, form_submissions, page_content, templates
2. `20261008120000_templates_and_settings.sql` — app_settings, site_settings tables
3. `20261008130000_storage.sql` — `products` (public) and `resources` (private) storage buckets + policies
4. `20261013120000_security_hardening.sql` — auto-provision profile trigger (role=viewer), `place_order` server-side validation, form-submission payload size limit, function grants
5. `20261013130000_least_privilege_and_storage.sql` — profiles.role defaults to `viewer`, resources bucket MIME allow-list
6. `20261013140000_owner_only_roles_and_execute_hardening.sql` — `is_owner()` helper, owner-only role change trigger, revoke `place_order` from `anon`
7. `20261015120000_checkout_integrity_social_and_location.sql` — `customer_phone` + `idempotency_key` on orders, social links on site_settings, indexes, updated `place_order()` with server-side pricing + stock pre-check, `apply_order_status_stock()` trigger
8. `20261017120000_order_tracking.sql` — public `track_order(order_number, phone)` RPC (two-factor lookup, PII-free projection, `SECURITY DEFINER`) + `order_tracking_attempts` throttle ledger

### Security

- RLS enabled on every table; default-deny when no policy matches
- `service_role` key is **never** used in Flutter code
- Credentials are injected via `--dart-define` (never hardcoded)
- `place_order()` is SECURITY DEFINER and validates all input server-side (client cannot dictate prices, totals, or bypass stock checks)
- Anonymous users cannot read customers, orders, profiles, or any private resource
- Public order tracking requires **both** the order number and the checkout phone; the `track_order()` RPC returns a PII-free projection and is rate-limited per caller
- Profile roles can only be changed by an owner (enforced by a BEFORE UPDATE trigger, not just RLS)
- Public sign-ups should be disabled in the Supabase dashboard (Authentication → Providers → Email)

---

## Requirements

- Flutter SDK stable channel (Dart `^3.13.4`)
- `flutter pub get` before first run

Check your version:
```bash
flutter --version
```

---

## Run

```bash
cd diali
flutter pub get

# Local / offline mode (no backend required, opens directly on Dashboard)
flutter run -d chrome

# Connected to Supabase (admin requires sign-in)
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

---

## Test

```bash
flutter test        # 110 tests — all pass
flutter analyze     # no issues
```

---

## Production build

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key> \
  --dart-define=APP_ENV=production
```

Output: `build/web/` — deploy to Netlify, Vercel, Cloudflare Pages, or Firebase Hosting.

For deployment details see [`docs/deployment-guide.md`](docs/deployment-guide.md).

---

## Localization

Three languages fully implemented:

| Language | Code | Direction |
|----------|------|-----------|
| Arabic | `ar` | RTL |
| English | `en` | LTR |
| Français | `fr` | LTR |

Switch via Settings → Language. The layout, navigation, forms, error messages and all UI text adapt immediately. The selection is persisted across restarts.

---

## Local storage (Hive)

- **Settings** — all user preferences (locale, theme mode, style, notifications, privacy, consent)
- **Catalog** — products, categories and image binaries in offline / local mode only
- **Images** — binary image data keyed by a `localimg://` reference

When Supabase is configured, the remote database is the source of truth for all business data. Local Hive data is not synchronized back to Supabase.

---

## Arabic / العربية

منصة إدارة أعمال متعددة اللغات مبنية بـ Flutter وتدعم العربية بالكامل مع تخطيط RTL صحيح.

---
