markdown# SafeMom

A maternal health mobile application for East African mothers, integrating pregnancy tracking, one-tap emergency response, and a moderated peer community.

Final project for Mobile Application Development course, African Leadership University.

## Team

- Samuel Chima Nkpado
- Uwase Ntwali Cynthia
- Kyle Ange-Aymeric Konan
- Nina Cyndy Bwiza
- Brenda Nyambura Maina

## Tech stack

- Flutter 3.41+
- Dart 3.x
- Firebase (Firestore, Authentication)
- BLoC state management
- Clean Architecture (presentation, domain, data layers)

## Project structure
lib/

├── core/           # Shared constants, theme, utilities, error classes

└── features/       # Each feature self-contained with data/domain/presentation

├── auth/

├── onboarding/

├── home/

├── symptoms/

├── emergency/

├── community/

└── profile/

## Setup instructions

### Prerequisites
- Flutter 3.41 or higher
- Android Studio with Android SDK 34+
- A physical Android device or Android emulator
- Firebase project (credentials required)

### Running the app

1. Clone the repository
git clone https://github.com/SamuelNkpado/safemom-app.git

cd safemom-app

2. Install dependencies
flutter pub get

3. Add Firebase configuration files (request from team lead):
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

4. Run on an Android device or emulator
flutter run

## Branching workflow

- `main` — production-ready code, protected branch
- `dev` — integration branch for completed features
- `feature/<name>` — individual feature branches per team member

All work must go through Pull Requests. PRs require at least one team review before merging.

## Screenshots

*Coming soon — added as features are completed.*

## License

Academic project — African Leadership University, 2026.
Save the file, then commit:
