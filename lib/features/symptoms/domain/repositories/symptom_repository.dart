import '../entities/symptom_log.dart';
import '../entities/danger_check.dart';

/// Contract for symptom logging and danger check operations.
///
/// The data layer implements this using Firestore.
abstract class SymptomRepository {
  // ---------- SYMPTOM LOGS ----------

  /// Save a new symptom log for the current user.
  ///
  /// Throws [SymptomException] on failure.
  Future<void> logSymptom(SymptomLog symptom);

  /// Fetch all symptom logs for a user, most recent first.
  Future<List<SymptomLog>> getUserSymptoms(String userId);

  /// Fetch symptoms logged during a specific pregnancy week.
  Future<List<SymptomLog>> getSymptomsInWeek({
    required String userId,
    required int week,
  });

  /// Fetch symptoms flagged as potential danger signs.
  Future<List<SymptomLog>> getFlaggedSymptoms(String userId);

  /// Update an existing symptom log (e.g., editing the note).
  Future<void> updateSymptom(SymptomLog symptom);

  /// Delete a symptom log.
  Future<void> deleteSymptom(String symptomId);

  /// Real-time stream of a user's symptom history.
  Stream<List<SymptomLog>> watchUserSymptoms(String userId);

  // ---------- DANGER CHECKS ----------

  /// Save a completed danger-sign check.
  Future<void> saveDangerCheck(DangerCheck check);

  /// Fetch a user's danger check history, most recent first.
  Future<List<DangerCheck>> getUserDangerChecks(String userId);
}

/// Base exception for symptom-related failures.
class SymptomException implements Exception {
  final String message;
  final String? code;

  const SymptomException(this.message, {this.code});

  @override
  String toString() => 'SymptomException($code): $message';
}