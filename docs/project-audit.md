# diali — Project Audit

> Generated from a full read of the existing repository (not hypothetical).
> Baseline verified before changes: `flutter analyze` → **clean**, `flutter test` → **38 passing**,
> Flutter 3.47.5 / Dart 3.13.4.

## 1. What the project is

`diali` is an existing Flutter business platform with three surfaces:

1. A **responsive admin dashboard** (shell with sidebar / nav-rail / drawer) exposing
   Dashboard, Products, Categories, Orders, Customers, Resources, Forms, Pages, Store, Settings.
2. A **storefront** page (catalog, cart, simulated checkout).
3. A **settings** page (language, appearance, style, notifications, privacy, data, about).

It is Arabic / English / French with RTL support, three visual styles
(Modern / Minimal / Professional), light / dark / system themes, and Hive local persistence.

## 2. Repository facts

- `diali/` is a **nested git repo** inside `/home/said/Documents/dirdialk`. Parent repo has no
  commits and no `.gitignore`.
- Current branch `main`, 3 commits, large amount of **uncommitted** work already present.
- No `supabase_flutter`, no `riverpod`, no `go_router` in `pubspec.yaml`. State is
  `ChangeNotifier` + `AppRepositories` singleton. Navigation is `IndexedStack` + `Navigator.push`.
- A full Supabase SQL schema exists at `supabase/migrations/20261008000000_initial_schema.sql`
  (multi-tenant, 11 tables) but **nothing consumes it** — there is no client dependency and no
  `Supabase.initialize` call anywhere.

## 3. What already works (preserve)

| Area | State |
|---|---|
| Responsive app shell | Sidebar (>=1100), nav-rail (720–1099), drawer (<720). Solid. |
| Design system | `app_colors`, `app_palette` (ThemeExtension), `app_theme`, `app_typography` (Inter + Cairo fallback), `app_spacing`, `app_style` (3 styles). |
| Localization | 259 keys × 3 (ar/en/fr), **key-complete and placeholder-consistent**. RTL/LTR wired via `MaterialApp` delegates. |
| Settings | `SettingsController` (ChangeNotifier) + Hive `SettingsStore`; language, theme, style, notifications, privacy, consent, reset, export. |
| Products / Categories | Full CRUD, images via `ImageService` (pick/crop/store in Hive bytes), Hive-persisted catalog, responsive tables. |
| Orders / Customers / Resources / Forms / Pages | CRUD screens over mock repositories with stats, filters, responsive tables + mobile cards. |
| Storefront | Banner carousel, category strip, featured/latest carousels, grid, cart bottom-sheet, checkout that creates an `Order`. |
| Images | `AppImage` resolves `localimg://`, assets, and network URLs with placeholder/error fallbacks. |
| Tests | 38 passing (shell, localization, themes, settings persistence/features, categories, demo seeder). |

## 4. What is incomplete

1. **No real backend.** All production screens read from in-memory mocks; only products/categories
   persist (Hive). Orders/customers/resources/forms/pages reset on restart.
2. **No authentication / authorization.** App opens straight to dashboard. Admin data is not protected.
3. **No public website distinct from the admin app.** The "store" page lives inside the admin shell.
4. **Website templates not implemented.** `lib/domain/models/template.dart` exists but is orphaned.
5. **Product tracking & locations not implemented.** `location.dart` and most of
   `product_tracking.dart` are orphaned; only `TrackingStatus` is referenced by `Product`.
6. **Settings partial.** No font-size / density / corner / shadow / direction controls despite
   `app_preferences.dart` defining them (also unused). Data reset only clears preferences, not records.
7. **Articles.** `PageContent` covers CMS pages but has no category, cover-image preview uses raw
   `Image.network`, and content renders as plain text.
8. **Localization gap.** Products, Orders, Customers, Resources, Forms, Pages and Store are
   hardcoded English; `ErrorStateView` and `ImageService` error strings are hardcoded.
9. **Write feedback missing.** Most create/update/delete `Result`s are ignored — no success/error UI.
10. **Store checkout incomplete.** Hardcoded customer, no stock decrement, tax hardcoded 8%.

## 5. What is duplicated / unnecessary (candidates)

| Item | Verdict | Reason |
|---|---|---|
| `lib/core/cart/*` (`CartController`, `CartScope`, `CartStorage`) | Consolidate | Complete but entirely unused; `StorePage` re-implements a cart. `CartStorage.restore` is broken by design. |
| `lib/shared/widgets/placeholder_page.dart` | Remove | Unused; its only consumer of `NavSection.phase`. |
| `NavSection.phase` | Remove | Only used by the dead `PlaceholderPage`. |
| `ProductThumbnail` in `product_image_manager.dart` | Remove | Unused widget. |
| `DemoCatalog.promoAsset`, `BannerDef.titleKey` | Remove/keep | Unused fields. |
| `AppPalette` unused fields | Keep | Harmless, small; part of design contract. |
| `app_preferences.dart` enums | Keep (wire up) | Intended for settings; wire font-size/density/direction. |
| Multi-tenant `organizations` schema | Replace | Prompt explicitly forbids multi-tenancy; repo is single-business. |

## 6. What is insecure

1. No authentication — any user reaching `/admin` sees all business data.
2. No RLS enforcement in practice (schema not deployed, no client).
3. Release Android manifest lacks `INTERNET` (network impossible in release until added).
4. Android `applicationId`/namespace `com.example.diali` + debug signing are template placeholders.
5. No secrets are currently in source (verified). `docs/backend-architecture.md` documents
   `--dart-define` usage.

## 7. What prevents Flutter Web from running correctly

- `web/` is standard and correct (`<base href="$FLUTTER_BASE_HREF">`). `build/web` is a **stale
  partial** build (missing `main.dart.js`), git-ignored.
- No routing: state + `IndexedStack` means **no deep links, no browser back, no refresh-safe URLs**.
- `manifest.json` uses Flutter default `#0175C2` (brand is `#3949AB`), placeholder description, and
  `portrait-primary` orientation lock — wrong for a dashboard web app.
- `index.html` description is the Flutter placeholder.
- No SPA fallback configuration documented for hosting.
- Network features (future Supabase) cannot work over HTTPS until web connectivity/CORS is configured.

## 8. What prevents production deployment

- No real backend configured (URL + publishable key absent).
- No hosting config / SPA rewrite / environment separation.
- No build validation for `flutter build web --release`.
- Admin is unauthenticated.

## 9. What must be preserved

- The entire design system and theme/style engine.
- The repository-interface pattern and `Result<T>` / `AppError` contracts.
- Hive persistence for settings and (optionally) catalog caching.
- The 259-key localization parity.
- Every working CRUD screen and its responsive behaviour.
- Bundled fonts (Inter/Cairo) and asset images.

## 10. Risks

| Risk | Mitigation |
|---|---|
| Rewriting the schema touches an undeployed spec | Replace, keep a clear migration history. |
| Adding `go_router` changes default landing route | Keep admin at `/admin`, update tests. |
| Supabase credentials unavailable | Config-driven; fall back to mock/in-memory so app still runs. |
| Large refactor could break the 38 green tests | Keep changes small; re-run analyze + tests continuously. |
| Deleting "unused" code that is actually a contract | Only remove after reference search; keep model contracts. |

## 11. Reference-safety notes

Before removing anything the following was checked: imports, route/nav usage, generated-code links,
build config, platform usage. See `implementation-plan.md` for the final removal list.
