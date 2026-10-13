# Agent Integration & Shared Data Contracts

> Status: **active coordination document** — updated continuously while Agents 1–3 work.

This document is the single source of truth for file ownership, shared data
contracts, and integration rules. It prevents two agents modifying the same
shared file at the same time and keeps the app compiling at every step.

## Project layout

```text
lib/
  main.dart                    # entry point (owned by Agent 1)
  app/app.dart                 # MaterialApp root (Agent 1)
  core/
    app_info.dart              # static version metadata (Agent 1)
    cart/                      # storefront cart scope (Agent 2)
    design_system/             # theme, style, spacing, preferences (Agent 1)
    navigation/                # NavSection enum (Agent 3 — categories added)
    settings/                  # SettingsController (Agent 1)
    storage/                   # Hive settings persistence (Agent 1)
  data/
    app_repositories.dart      # composition root for ALL repositories (Agent 3)
    mock/                      # in-memory repositories + seed data (Agent 3)
    supabase/                  # not implemented yet
  domain/
    models/                    # shared data contracts (see table below)
    repositories/              # abstract repository interfaces (Agent 3)
  features/
    shell/                     # responsive app shell + navigation (Agent 1/3)
    dashboard/                 # dashboard (Agent 3)
    products|orders|customers|resources|forms|pages|store|settings|categories
  shared/widgets/              # reusable widgets (Agent 1)
  l10n/                        # ARB + generated localizations (Agent 1 owns .arb parity)
test/
```

## Ownership matrix (shared files)

Only one agent edits these files at a time.

| File(s) | Owner | Notes |
| --- | --- | --- |
| `lib/core/settings/*`, `lib/core/storage/*` | **Agent 1** | persistence + controller |
| `lib/core/design_system/*`, `lib/core/app_info.dart` | **Agent 1** | theme/style/spacing |
| `lib/l10n/app_*.arb` + `generated/*` | **Agent 1** | ARB parity, gen-l10n |
| `lib/domain/models/*` | **Agent 1 (contracts)** | model shape changes must be coordinated |
| `lib/domain/repositories/*` | **Agent 3** | abstract interfaces |
| `lib/data/app_repositories.dart`, `lib/data/mock/*` | **Agent 3** | wiring + seed data |
| `lib/features/shell/app_shell.dart`, `lib/core/navigation/nav_section.dart` | **Agent 3 (impl), Agent 1 (styles)** | coordinate refactors |
| `lib/features/categories/*`, `lib/features/dashboard/*` | **Agent 3** | admin feature |
| `lib/features/store/*`, `lib/core/cart/*` | **Agent 2** | customer-facing storefront |
| `lib/features/resources|forms|pages/*` | **Agent 2** | content feature |
| `lib/features/products|orders|customers/*` | **Agent 1/3** | admin data pages |
| `lib/features/settings/*` | **Agent 1** | settings UI |
| `lib/shared/widgets/*` | **Agent 1** | shared UI |
| `test/*` | Owner of feature | keep `flutter test` green |

## Data contracts

All repositories return `Result<T>` (sealed: `Success<T>`/`Failure<AppError>`).
`PaginatedResult<T>` wraps paged lists.

| Model | File | Key fields | Owner |
| --- | --- | --- | --- |
| `Product` | `domain/models/product.dart` | id, name, sku, categoryId/Name, price, costPrice, stockQty, lowStockThreshold, trackingStatus, locationId/Name | Agent 1 |
| `ProductTracking` / `TrackingStatus` / `TrackingEvent` | `product_tracking.dart` | events, status flow (created → inStock → shipped → delivered …) | Agent 1 |
| `Category` | `category.dart` | id, name, slug, description, productCount | Agent 3 |
| `Customer` | `customer.dart` | id, name, email, phone, tier, totalSpent, ordersCount | Agent 1 |
| `Order` | `order.dart` | id, orderNumber, customerId/Name, items, total, status | Agent 1 |
| `Resource` | `resource.dart` | id, name, category, type, sizeBytes, isPublished | Agent 2 |
| `FormDefinition` | `form_definition.dart` | id, title, fields, submissions | Agent 2 |
| `PageContent` | `page_content.dart` | id, title, slug, seo, status | Agent 2 |
| `Location` | `location.dart` | id, name, type, address, geo | Agent 1 (against) |
| `Template` | `template.dart` | id, name, slug, category, customization | Agent 2 (against) |
| `AppError` | `app_error.dart` | code, message, statusCode | Agent 3 |
| `StoreSettings` | *(planned)* | brand, colors, contact | Agent 1/2 — not yet created |

## Integration decision log

- **Navigation**: `NavSection` gained `categories` (Agent 3). `AppShell` maps
  enum order to `IndexedStack` index — any new section must be appended, and
  both `nav_section.dart` and `app_shell.dart` change in the same commit.
- **Repositories**: `AppRepositories.instance` is the single composition root.
  UIs must never instantiate repositories directly.
- **Settings**: `SettingsController` is a `ChangeNotifier` injected from
  `main.dart` and passed to `DialiApp`/`AppShell`. New preferences go through
  the controller + `SettingsStore`, never `SharedPreferences` or a second
  storage system.
- **Storefront cart**: Agent 2 maintains `core/cart/*`. Store page consumes
  `ProductRepository` by contract; order creation flows through `OrderRepository`.
- **Outstanding lint (Agent 2)**: `lib/core/cart/cart_storage.dart:6`
  (`unused_field` `_key`) and `:15` (`prefer_interpolation_to_compose_strings`)
  — awaiting Agent 2 to fix so `flutter analyze` can be fully clean.
- **Unused models**: `location.dart`, `template.dart`, and
  `design_system/app_preferences.dart` are staged but not referenced by UI yet.
  Agent 1 keeps them as contracts; do not delete without discussion.

## Verified baseline (Agent 1, latest run)

- `flutter analyze` → clean for Agent 1 files (2 infos remain in Agent 2's cart file).
- `flutter test` → **13 + 11 = 24 tests passing** (app/shell + settings features
  + settings persistence).
- `flutter build web` → verified (see README).