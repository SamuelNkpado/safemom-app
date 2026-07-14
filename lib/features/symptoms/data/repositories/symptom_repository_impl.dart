import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/danger_check.dart';
import '../../domain/entities/symptom_log.dart';
import '../../domain/repositories/symptom_repository.dart';
import '../datasources/symptom_firestore_datasource.dart';
import '../models/danger_check_model.dart';
import '../models/symptom_log_model.dart';

/// Concrete implementation of [SymptomRepository] backed by Firestore.
///
/// Delegates work to the Firestore datasource, converts entities to
/// models for persistence, and translates Firebase exceptions into
/// domain-level [SymptomException]s.
class SymptomRepositoryImpl implements SymptomRepository {
  final SymptomFirestoreDatasource _datasource;

  SymptomRepositoryImpl(this._datasource);

  // ---------- SYMPTOM LOGS ----------

  @override
  Future<void> logSymptom(SymptomLog symptom) async {
    try {
      final model = SymptomLogModel.fromEntity(symptom);
      await _datasource.logSymptom(model);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<List<SymptomLog>> getUserSymptoms(String userId) async {
    try {
      return await _datasource.getUserSymptoms(userId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<List<SymptomLog>> getSymptomsInWeek({
    required String userId,
    required int week,
  }) async {
    try {
      return await _datasource.getSymptomsInWeek(userId: userId, week: week);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<List<SymptomLog>> getFlaggedSymptoms(String userId) async {
    try {
      return await _datasource.getFlaggedSymptoms(userId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<void> updateSymptom(SymptomLog symptom) async {
    try {
      final model = SymptomLogModel.fromEntity(symptom);
      await _datasource.updateSymptom(model);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<void> deleteSymptom(String symptomId) async {
    try {
      await _datasource.deleteSymptom(symptomId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Stream<List<SymptomLog>> watchUserSymptoms(String userId) {
    return _datasource.watchUserSymptoms(userId);
  }

  // ---------- DANGER CHECKS ----------

  @override
  Future<void> saveDangerCheck(DangerCheck check) async {
    try {
      final model = DangerCheckModel.fromEntity(check);
      await _datasource.saveDangerCheck(model);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<List<DangerCheck>> getUserDangerChecks(String userId) async {
    try {
      return await _datasource.getUserDangerChecks(userId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- ERROR TRANSLATION ----------

  SymptomException _translateException(FirebaseException e) {
    final code = e.code;
    switch (code) {
      case 'permission-denied':
        return const SymptomException(
          'You do not have permission to access this data. '
              'Please sign in again.',
          code: 'permission-denied',
        );
      case 'unavailable':
      case 'deadline-exceeded':
        return const SymptomException(
          'Could not reach the server. Please check your connection '
              'and try again.',
          code: 'service-unavailable',
        );
      case 'not-found':
        return const SymptomException(
          'This record could not be found.',
          code: 'not-found',
        );
      case 'network-request-failed':
        return const SymptomException(
          'No internet connection. Please try again when you are online.',
          code: 'network-error',
        );
      default:
        return SymptomException(
          e.message ?? 'Something went wrong. Please try again.',
          code: code,
        );
    }
  }
}