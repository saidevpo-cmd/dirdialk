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

Phase 0 / Phase 1 — Base application:

- App Shell + Navigation
- Dashboard with demo data
- Settings: Language, Appearance mode, Style
- Arabic / English / Français with RTL + LTR
- Light / Dark / System theme
- Style switching (Modern / Minimal / Professional)
- Responsive layout (desktop, laptop, tablet, mobile)
- Local persistence for user settings

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
    storage/                # local settings persistence (no backend)
    settings/               # settings controller
    navigation/             # navigation definitions
  features/
    shell/                  # responsive app shell + navigation
    dashboard/              # dashboard page
    settings/               # language, appearance, style
  shared/
    widgets/                # reusable UI components
  l10n/                     # localization files
```

## Quick start

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app
4. Run `flutter test` to verify everything works

