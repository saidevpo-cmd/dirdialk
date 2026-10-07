# Project Plan - diali

## Overview
diali is a Flutter-based multilingual business platform. This is Phase 0/1 focusing on the base application with core infrastructure, localization, theming, and navigation.

## Project Phases

### Phase 0 - Foundation (Current)
- [x] Flutter project setup with proper structure
- [x] Core design system (colors, typography, spacing, theme, styles)
- [x] Local storage implementation with Hive
- [x] Settings management and persistence
- [x] App localization (Arabic, English, French) with RTL/LTR support
- [x] Responsive app shell with navigation (sidebar, rail, drawer)
- [x] Dashboard page with demo data
- [x] Settings page (language, appearance, style)
- [x] Theme system with multiple styles (Modern, Minimal, Professional)
- [x] Widget tests for core functionality

### Phase 1 - Base Application (Current State)
Status as described in README: "Base application with no login/register/roles. App opens directly to Dashboard."

### Phase 2 - Products (Planned)
According to nav sections, Products is planned for Phase 2. Features to implement:
- Product listing
- Product management (add/edit/delete)
- Categories
- Inventory tracking

### Phase 3 - Categories (Implied)
Part of product management

### Phase 4 - Storefront (Phase 5 in nav)
- Customer-facing storefront
- Product browsing
- Cart functionality

### Phase 5 - Orders & Customers (Phase 6)
- Order management
- Customer management
- Order tracking

### Phase 6 - Resources (Phase 7)
- Resource management

### Phase 7 - Forms (Phase 8)
- Form builder/management

### Phase 8 - Pages (Phase 9)
- Content page management

## Architecture

### Directory Structure
```
lib/
├── app/                      # App root configuration
├── core/
│   ├── design_system/       # Theming, styling, design tokens
│   ├── navigation/          # Navigation definitions
│   ├── settings/            # Settings controller
│   └── storage/             # Local persistence (Hive)
├── features/
│   ├── shell/               # Responsive app shell
│   ├── dashboard/           # Dashboard
│   └── settings/            # Settings UI
├── l10n/                    # Localization files
├── shared/
│   └── widgets/             # Reusable widgets
└── main.dart                # Entry point
```

### Key Technologies
- Flutter 3.47.5
- Dart 3.13.4
- Hive for local storage
- flutter_localizations for i18n
- Material 3 design

## Current Features

### Navigation
- Responsive layout adapting to screen size:
  - Desktop (>= 1100px): Sidebar navigation
  - Tablet (720-1099px): Navigation rail
  - Mobile (< 720px): Drawer navigation with app bar
- 9 navigation sections: Dashboard, Products, Orders, Customers, Resources, Forms, Pages, Store, Settings

### Internationalization
- 3 supported languages: Arabic (ar), English (en), French (fr)
- RTL support for Arabic
- Proper localization with ARB files and generated code

### Theming
- Light/Dark/System theme modes
- 3 visual styles:
  - Modern: Rounded corners, colorful, friendly
  - Minimal: Flat, sharp, clean
  - Professional: Compact, formal, dense
- Style configuration affects spacing, radius, shadows, typography

### Settings Persistence
- Local storage using Hive
- Settings persist across app restarts
- Fallback to in-memory storage if Hive initialization fails

### Dashboard
- Statistics cards (Products, Orders, Customers, Resources)
- Recent activity feed
- Quick actions
- Responsive grid layout

## Testing
All widget tests passing (14 tests total):
1. App opens directly to dashboard without login
2. Desktop navigation works
3. Arabic with RTL layout
4. English with LTR layout
5. French localization
6. Light mode
7. Dark mode and switching
8. Style switching
9. Settings persistence
10. Responsive layout adaptation
11. Quick actions navigation
12. View all navigation

## Running the App
```bash
flutter pub get
flutter run
```

## Development Commands
```bash
flutter test      # Run tests
flutter analyze   # Static analysis
flutter pub get   # Install dependencies
```

## Next Steps
- Implement remaining feature modules based on planned phases
- Add more comprehensive tests as features are added
- Enhance dashboard with real data integration
