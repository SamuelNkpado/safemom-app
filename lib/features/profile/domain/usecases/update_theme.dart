import '../entities/user_preferences.dart';
import '../repositories/preferences_repository.dart';

/// Business operation: change the app's theme mode.
///
/// No custom validation is needed — the [ThemeMode] enum enforces valid
/// values at compile time. This use case exists mainly to keep the UI
/// layer thin and to give the PDF report a "3+ preferences" story.
class UpdateTheme {
  final PreferencesRepository repository;

  UpdateTheme(this.repository);

  /// Executes the theme change.
  ///
  /// Throws [PreferencesException] if the local storage write fails.
  Future<void> call({required ThemeMode themeMode}) async {
    return repository.setThemeMode(themeMode);
  }
}