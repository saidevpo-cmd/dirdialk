<div dir="auto">

# diali

<a id="english"></a>

**English** | [العربية](#العربية)

A Flutter application. The base for a multilingual business platform:
Dashboard, Products, Categories, Orders, Customers, Resources, Forms, Pages
and a local Storefront.

**No login. No register. No roles.** The app opens directly on the Dashboard.

---

## Status

Phase 0 / Phase 1 — Base application + local-first product images:

- App Shell + Navigation
- Dashboard with demo data
- Products & Categories with local image management
  - Pick images from the device (gallery) with optional crop
  - Multi-image product galleries (set main image, replace, remove, reorder)
  - Images persisted locally (bytes stored in Hive, web-safe)
  - Asset fallbacks and placeholders for missing images
- Storefront with promotional banner carousel, category strip,
  featured/latest product carousels and an in-app cart (creates an order)
- Repeat-safe demo data loader (Settings → Data) with 12 products,
  6 categories and banner images — never overwrites existing data
- Settings: Language, Appearance mode, Style, Notifications, Privacy, Data
- Arabic / English / Français with RTL + LTR
- Light / Dark / System theme
- Style switching (Modern / Minimal / Professional)
- Responsive layout (desktop, laptop, tablet, mobile)
- Local persistence for user settings and catalog data

Backend, GitHub and Authentication are **not** part of this phase.

---

## Requirements

- Flutter SDK (stable channel)
- Dart SDK `^3.13.4`

Check with:

```bash
flutter --version
```

## Run

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter test
```

## Analyze

```bash
flutter analyze
```

---

## Project structure

```text
lib/
  main.dart                 # entry point
  app/                      # app root: locale, theme, navigation
  core/
    design_system/          # AppColors, Typography, Spacing, Radius, Theme
    images/                 # ImageStore, ImageService, AppImage helpers
    storage/                # local settings + catalog persistence (Hive/InMemory)
    settings/               # settings controller
    navigation/             # navigation definitions
  domain/
    models/                 # Product, Category, Order, etc.
    repositories/           # repository interfaces
  data/
    app_repositories.dart   # shared repository wiring (configure/reset)
    mock/                   # in-memory + persistent catalog repositories
    demo/                   # demo catalog + repeat-safe demo seeder
  features/
    shell/                  # responsive app shell + navigation
    dashboard/              # dashboard page
    products/               # product list, details, image manager/gallery
    categories/             # category list + image field
    orders/                 # orders page
    store/                  # storefront carousels + cart
    settings/               # language, appearance, style, data
  shared/
    widgets/                # reusable UI components (AppCard, AppImage, etc.)
  l10n/                     # localization files
assets/
  images/                   # bundled demo assets (products/categories/banners)
tool/
  generate_demo_assets.dart # regenerates the bundled demo images
```

## Quick start

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app
4. Run `flutter test` to verify everything works

# dirdialk
