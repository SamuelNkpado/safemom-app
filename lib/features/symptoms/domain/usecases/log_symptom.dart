import '../entities/symptom_log.dart';
import '../repositories/symptom_repository.dart';

/// Business operation: log a symptom for the current user.
///
/// Enforces clinical constraints before persisting:
/// - severity must be within the accepted 1–5 range
/// - pregnancy week must be within a valid pregnancy range
/// - optional notes have a length limit to prevent abuse
///
/// Also determines whether the symptom should be flagged as a potential
/// danger sign based on type and severity. This is a lightweight rule —
/// deeper triage is done in a separate use case (RunDangerCheck).
class LogSymptom {
  final SymptomRepository repository;

  LogSymptom(this.repository);

  /// Executes the log-symptom flow.
  ///
  /// Throws [ArgumentError] on validation failure.
  /// Throws [SymptomException] if persistence fails.
  Future<void> call({
    required String symptomId,
    required String userId,
    required SymptomType symptomType,
    required int severity,
    required int pregnancyWeek,
    String? note,
    DateTime? loggedAt,
  }) async {
    // ---------- VALIDATION ----------

    if (userId.trim().isEmpty) {
      throw ArgumentError('User must be signed in to log a symptom.');
    }

    if (severity < 1 || severity > 5) {
      throw ArgumentError('Severity must be between 1 and 5.');
    }

    if (pregnancyWeek < 1 || pregnancyWeek > 45) {
      throw ArgumentError(
        'Pregnancy week must be between 1 and 45.',
      );
    }

    if (note != null && note.length > 500) {
      throw ArgumentError('Note must be under 500 characters.');
    }

    // ---------- BUSINESS LOGIC ----------

    // Auto-flag as potential danger if severity is high AND the symptom
    // type is one of the known danger indicators. The user always sees
    // the danger checker as a follow-up in the UI regardless.
    final isPotentiallyDangerous =
        _isDangerType(symptomType) && severity >= 4;

    final symptom = SymptomLog(
      symptomId: symptomId,
      userId: userId,
      symptomType: symptomType,
      severity: severity,
      note: note?.trim(),
      pregnancyWeek: pregnancyWeek,
      loggedAt: loggedAt ?? DateTime.now(),
      flaggedAsDanger: isPotentiallyDangerous,
    );

    // ---------- PERSIST ----------

    return repository.logSymptom(symptom);
  }

  /// Symptom types that warrant a danger-check prompt at high severity.
  ///
  /// This is a screening heuristic, not a diagnosis. The real evaluation
  /// happens in the danger-check use case.
  bool _isDangerType(SymptomType type) {
    return type == SymptomType.bleeding ||
        type == SymptomType.contractions ||
        type == SymptomType.reducedFetalMovement ||
        type == SymptomType.dizziness ||
        type == SymptomType.headache;
  }
}