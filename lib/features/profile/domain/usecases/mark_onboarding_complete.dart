import '../repositories/preferences_repository.dart';

/// Business operation: mark that the user has finished onboarding.
///
/// Called once, at the end of the onboarding flow. On subsequent app
/// launches the app checks this flag and skips onboarding if true.
///
/// Idempotent — calling it multiple times is safe.
class MarkOnboardingComplete {
  final PreferencesRepository repository;

  MarkOnboardingComplete(this.repository);

  /// Executes the mark-complete flow.
  ///
  /// Throws [PreferencesException] if the local storage write fails.
  Future<void> call() async {
    return repository.markOnboardingComplete();
  }
}