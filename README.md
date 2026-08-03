# 🏆 SPORTO Enterprise Mobile Platform

> **Production-Grade Monorepo for Multi-Sport Match Scoring, Tournament Management, & Official Referee Portals**  
> Built with **Flutter**, **Clean Architecture**, **Strict Event-Driven BLoC**, **Local-First Hive Storage**, and a **Glassmorphism Design System (`#F4B41A` Amber Gold)**.

---

## 📌 Architecture & Design Highlights

1. **Melos Monorepo Architecture**:
   - 5 decoupled internal packages (`core`, `ui_kit`, `shared_domain`, `partner_data`, `referee_data`).
   - 2 native mobile applications (`apps/partner_app` for Organizers/Turf Owners, `apps/referee_app` for Official Umpires/Scorekeepers).

2. **Extensible Multi-Sport Strategy Pattern**:
   - `ISportScoreEngine<T, E>` interface allowing seamless runtime addition of Cricket, Football, Basketball, Badminton, etc.
   - Dynamic resolution via `SportEngineFactory.getEngine(SportType.cricket)`.

3. **Mobile Number OTP & Automated Onboarding**:
   - `PhoneLoginScreen`: Mobile Number input card with country code dropdown (`+91`, `+1`, etc.) + 4-digit PIN verification modal.
   - `AutomatedOnboardingWizard`: Automated 4-step user onboarding flow (Personal Information, Location & Notification Permissions, Favorite Sports Selection Grid, Feature Showcase Carousel).

4. **Figma Glassmorphism Design System (`packages/ui_kit`)**:
   - Consumes Flutter Material 3 `Theme.of(context).colorScheme` dynamically.
   - **Primary Brand Color**: **`#F4B41A` (Vibrant Amber Gold)** extracted directly from Figma hero nodes.
   - Frosted translucent glass containers (`BackdropFilter` with blur `15px-25px`), glowing amber strokes (`rgba(244, 180, 26, 0.35)`), obsidian background (`#0E0C08`), and dark slate surface panels (`#1C2026`).

5. **Local-First Offline Sync Engine (`packages/core`)**:
   - Zero-delay optimistic UI updates backed by local **Hive Boxes**.
   - Offline actions logged into `sporto_pending_sync_box`.
   - `ConnectivityBloc` monitors network status via `connectivity_plus` and automatically flushes sync queue when online.

---

## 📁 Repository Structure

```
E:\syed_moiz_ali\personal\sporto\
├── melos.yaml                            # Melos monorepo configuration
├── pubspec.yaml                          # Root workspace specification
├── README.md                             # Platform documentation
├── .gitignore                            # Root gitignore rules
├── login/ & signup/                      # Figma design asset exports
├── packages/
│   ├── core/                             # AuthBloc, ConnectivityBloc, HiveService, SyncQueueItem
│   ├── ui_kit/                           # Theme.of(context).colorScheme Glassmorphism System & Screens
│   ├── shared_domain/                    # Entities, Repositories Interfaces, Multi-Sport Engine Strategy
│   ├── partner_data/                     # Tournament Hive Data Sources & Repositories Impl
│   └── referee_data/                     # Match Hive Data Sources & Repositories Impl
└── apps/
    ├── partner_app/                      # Partner Mobile App (Android & iOS)
    └── referee_app/                      # Referee Mobile App (Android & iOS)
```

---

## 🚀 Getting Started & Monorepo Commands

### 1. Prerequisites
- **Flutter SDK**: `>=3.0.0`
- **Dart SDK**: `>=3.0.0 <4.0.0`
- **Melos CLI**: Installed via `dart pub global activate melos`

### 2. Monorepo Setup & Package Linking
```bash
# Bootstrap all 7 monorepo packages and link internal dependencies
dart run melos bootstrap
```

### 3. Run Static Code Analysis across Monorepo
```bash
# Run flutter analyze across all packages with zero fatal infos
dart run melos run analyze
```

---

## 📱 Running Mobile Applications

### SPORTO Partner Application (`apps/partner_app`)
Application for Tournament Organizers, League Hosts, and Turf/Ground Owners.

```bash
cd apps/partner_app

# Run on target Android device/emulator
flutter run -d android

# Run on target iOS device/simulator
flutter run -d ios
```

### SPORTO Referee Application (`apps/referee_app`)
Application for Official Umpires, Referees, and Live Scorekeepers with 3D Coin Toss Simulator and Ball-by-Ball Engine.

```bash
cd apps/referee_app

# Run on target Android device/emulator
flutter run -d android

# Run on target iOS device/simulator
flutter run -d ios
```

---

## 🛡️ License & Credits
- **Client**: SPORTO Mobile Platform.
- **Engine**: Powered by SPORTO Core Engine v1.0.0.
