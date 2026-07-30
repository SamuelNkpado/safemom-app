# SafeMom — Maternal Health Companion

SafeMom is a cross-platform mobile application that supports expectant mothers through pregnancy tracking, symptom logging, danger-sign screening, emergency dispatch, and a moderated peer community. It is built with **Flutter** and **Google Firebase**, structured around **Clean Architecture** with the **BLoC** state-management pattern.

**Repository:** https://github.com/SamuelNkpado/safemom-app
**Firebase project:** `safemom-bd26b` (region: `africa-south1`)
**Platform target:** Android (physical device or emulator). This is a mobile application; web/desktop builds are out of scope.

---

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Architecture](#architecture)
4. [Project Structure](#project-structure)
5. [Prerequisites](#prerequisites)
6. [Setup & Installation](#setup--installation)
7. [Firebase Configuration](#firebase-configuration)
8. [Running the App](#running-the-app)
9. [Testing](#testing)
10. [Database & Security](#database--security)
11. [Screenshots](#screenshots)
12. [Known Limitations & Future Work](#known-limitations--future-work)
13. [Team](#team)

---

## Overview

SafeMom is designed for expectant mothers, with a focus on the East African context. The app combines routine pregnancy tracking with safety-critical features: a two-tier danger-sign checker and a one-tap emergency dispatch flow that routes high-risk screening results directly to help.

The application follows a strict separation of concerns — presentation, domain, and data layers — so that business logic never lives inside UI files. State is managed with BLoC, dependencies are injected via GetIt, and all persistent data is stored in Cloud Firestore behind authenticated, owner-scoped security rules.

---

## Features

| Feature | Description |
|---|---|
| **Authentication** | Email/password and Google Sign-In. Secure registration, login, logout, and password reset. Auth state persists across app restarts. |
| **Home Dashboard** | Personalised greeting, current pregnancy week and trimester, progress indicator, baby-size comparison, quick actions, and a weekly tip. |
| **Symptom Logging** | Log symptoms with a severity rating; view history. |
| **Safety Check (Danger-Sign Checker)** | Eight danger indicators categorised into high- and medium-risk. High-risk results surface a "Get help now" action that routes directly to emergency dispatch. |
| **Emergency Dispatch** | SOS button (raised, always accessible in the bottom navigation) initiates an emergency request, shows live status, driver/ETA information, and partner-notification status, with a cancel option. |
| **Community** | Dynamic group loading, anonymous post creation with photo attachments (URL-based), post detail with replies, and post/reply deletion. |
| **Profile & Preferences** | Editable preferences persisted locally via SharedPreferences: theme (light/dark), notifications, and language. Sign-out clears session state. |

---

## Architecture

SafeMom implements **Clean Architecture** with three layers per feature module:

```
Presentation  ──►  Domain  ◄──  Data
   (UI, BLoC)     (entities,    (models,
                   use cases,    datasources,
                   repository     repository
                   interfaces)    implementations)
```

- **Presentation** — Flutter widgets and BLoC classes. UI reacts to state; it contains no business logic.
- **Domain** — Pure Dart. Entities, repository *interfaces*, and use cases. No Flutter or Firebase dependencies.
- **Data** — Firestore/Firebase-facing models, datasources, and concrete repository implementations that fulfil the domain interfaces.

**State management:** BLoC (`flutter_bloc`).
**Dependency injection:** GetIt, configured in `lib/core/di/`.
**Navigation:** Centralised named routes via `onGenerateRoute` in `lib/core/router/`.

---

## Project Structure

```
lib/
├── core/
│   ├── constants/        # colors, spacing, radius
│   ├── di/               # GetIt dependency injection
│   ├── navigation/       # main nav shell (bottom nav host)
│   ├── router/           # named routes + route table
│   ├── theme/            # app theme, text styles
│   └── widgets/          # shared reusable widgets
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── home/
│   ├── symptoms/
│   ├── community/
│   ├── emergency/
│   └── profile/
├── firebase_options.dart
└── main.dart
```

Each feature folder repeats the `data / domain / presentation` split. Business logic lives in `domain` (use cases) and `presentation` (BLoCs), never in widget files.

---

## Prerequisites

- **Flutter SDK** (stable channel) — run `flutter doctor` and resolve any issues before building.
- **Dart SDK** (bundled with Flutter).
- **Android Studio** (or VS Code) with the Flutter and Dart plugins.
- An **Android device** (USB debugging enabled) or an **Android emulator** (e.g. Pixel 5, API 33+).
- A **Google/Firebase account** with access to the project, or your own Firebase project (see below).

---

## Setup & Installation

```bash
# 1. Clone the repository
git clone https://github.com/SamuelNkpado/safemom-app.git
cd safemom-app

# 2. Install dependencies
flutter pub get

# 3. Verify your toolchain
flutter doctor
```

---

## Firebase Configuration

The repository includes a `firebase_options.dart` generated for the `safemom-bd26b` project. If you are running against **the existing project** (you have been granted access), no further Firebase setup is required beyond ensuring your `google-services.json` is present in `android/app/`.

If you are wiring up **your own Firebase project**, do the following:

1. **Create a Firebase project** in the [Firebase Console](https://console.firebase.google.com/).
2. **Register an Android app** with the package name `rw.alu.safemom.safemom` and download the `google-services.json` into `android/app/`.
3. **Regenerate options** with the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
4. **Enable Authentication → Sign-in methods:**
    - **Email/Password** — enable.
    - **Google** — enable, and set the project support email. For Google Sign-In on Android, ensure your SHA-1 (and SHA-256) debug/release fingerprints are added to the Android app in Firebase settings, then re-download `google-services.json`.
5. **Enable Cloud Firestore** (in the `africa-south1` region for parity with the primary project).
6. **Deploy security rules and indexes** (see below).

### Deploying Firestore rules & indexes

The repository version-controls both the security rules and the composite indexes:

```bash
# Requires the Firebase CLI: npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules,firestore:indexes
```

`firestore.indexes.json` declares the composite indexes required by the community feed and the emergency status stream. Without them, those queries fail with a `FAILED_PRECONDITION` error.

---

## Running the App

```bash
# List available devices
flutter devices

# Run in debug mode on a connected device/emulator
flutter run

# Build a release APK (used for the demo recording)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

To install the release APK on a physical device:

```bash
flutter install
# or
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Testing

The project includes widget and unit tests covering the auth, community, and emergency BLoCs and supporting logic.

```bash
# Run all tests
flutter test

# Run with coverage (outputs coverage/lcov.info)
flutter test --coverage
```

To generate a human-readable coverage report from `lcov.info`:

```bash
# Requires lcov (Linux/macOS) or an equivalent viewer
genhtml coverage/lcov.info -o coverage/html
```

**Static analysis** — the project targets a clean analyzer:

```bash
flutter analyze
dart format .
```

---

## Database & Security

**Data store:** Cloud Firestore.

Data is organised into collections that mirror the project ERD (see `docs/`), including users, symptom logs, danger checks, community groups, group memberships, posts, replies, emergency requests, appointments, and preferences.

**Security rules** enforce that:
- Every read and write requires an authenticated user.
- Owner-scoped records (e.g. a user's own symptom logs, danger checks, emergency requests) are readable/writable only by their owner.
- Community content follows author-scoped write/delete rules.

**Indexes** — composite indexes are declared in `firestore.indexes.json` for:
- `posts` — `group_id (ASC)`, `created_at (DESC)` for ordered group feeds.
- `emergency_requests` — `status (ASC)`, `user_id (ASC)`, `created_at (DESC)` for the live SOS status stream.

A full explanation of the security-rule design is provided in the project report.

---

## Screenshots

> _Screenshots to be added. Include: Welcome/Onboarding, Home dashboard, Symptom logging, Safety check (with high-risk result), Emergency dispatch (active), Community feed, and Profile. Recommended: a `docs/screenshots/` folder referenced here._

---

## Known Limitations & Future Work

- **Community post editing:** posts support create, read, and delete; in-place editing of an existing post is not yet implemented.
- **Emergency dispatch backend:** driver assignment and ETA are provided by the request-handling layer; integration with a real ambulance-dispatch service is future work.
- **Photo attachments:** community photos are attached by URL rather than uploaded to Firebase Storage (Storage requires the Blaze billing plan).
- **Localisation:** the language preference is stored and selectable; full translation of all strings is future work.
- **Offline support:** the app assumes connectivity; offline caching and sync are not yet implemented.

---

## Team

| Member | Area |
|---|---|
| Samuel Nkpado | Backend lead, merge coordination, emergency & integration |
| Kyle Ange-Aymeric Konan | Design system & authentication |
| Uwase Ntwali Cynthia | Home, symptoms & profile |
| Brenda Nyambura Maina | Community & emergency screens |
| Nina Cyndy Bwiza | Safety check & password-reset confirmation |

---

_Built as a summative software engineering project at African Leadership University._