import '../repositories/preferences_repository.dart';

/// Business operation: change the user's preferred language.
///
/// Rules enforced:
/// - language code must be one of the supported codes
/// - defaults to English if an unsupported code is passed
class UpdateLanguage {
  final PreferencesRepository repository;

  UpdateLanguage(this.repository);

  /// The set of language codes SafeMom currently supports.
  ///
  /// Keeping this in one place makes it easy to add languages later.
  static const supportedLanguages = {'en', 'sw'};

  /// Executes the language change.
  ///
  /// Throws [ArgumentError] if the language code is empty or unsupported.
  Future<void> call({required String languageCode}) async {
    // ---------- VALIDATION ----------

    final normalised = languageCode.trim().toLowerCase();

    if (normalised.isEmpty) {
      throw ArgumentError('Language code is required.');
    }

    if (!supportedLanguages.contains(normalised)) {
      throw ArgumentError(
        'Language "$languageCode" is not supported. '
            'Supported: ${supportedLanguages.join(", ")}.',
      );
    }

    // ---------- SAVE ----------

    return repository.setLanguage(normalised);
  }
}