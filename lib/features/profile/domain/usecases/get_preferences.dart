import '../entities/user_preferences.dart';
import '../repositories/preferences_repository.dart';

/// Business operation: fetch the current user preferences from local storage.
///
/// Returns [UserPreferences.defaults] if nothing has been stored yet
/// (fresh install, first launch).
///
/// This is the pure read use case — no validation needed since there
/// is no input.
class GetPreferences {
  final PreferencesRepository repository;

  GetPreferences(this.repository);

  /// Executes the fetch.
  ///
  /// Throws [PreferencesException] if the local storage read fails
  /// (rare — usually only when SharedPreferences hasn't initialised).
  Future<UserPreferences> call() async {
    return repository.getPreferences();
  }
}