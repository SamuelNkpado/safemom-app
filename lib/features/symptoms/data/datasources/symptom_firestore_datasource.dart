import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/danger_check_model.dart';
import '../models/symptom_log_model.dart';

/// Low-level data source that wraps the symptom_logs and danger_checks
/// Firestore collections.
///
/// Handles all reads, writes, and real-time streams for symptom tracking
/// and danger checks. Both collections live under this datasource because
/// they share the same repository interface.
class SymptomFirestoreDatasource {
  final FirebaseFirestore _firestore;

  SymptomFirestoreDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _symptomsCollection =>
      _firestore.collection('symptom_logs');

  CollectionReference<Map<String, dynamic>> get _dangerChecksCollection =>
      _firestore.collection('danger_checks');

  // ---------- SYMPTOM LOGS ----------

  /// Add a symptom log document.
  ///
  /// Uses the entity's symptomId if it's non-empty, otherwise Firestore
  /// generates an ID.
  Future<void> logSymptom(SymptomLogModel symptom) async {
    if (symptom.symptomId.isNotEmpty) {
      await _symptomsCollection
          .doc(symptom.symptomId)
          .set(symptom.toFirestore());
    } else {
      await _symptomsCollection.add(symptom.toFirestore());
    }
  }

  /// Fetch all symptoms for a user, most recent first.
  Future<List<SymptomLogModel>> getUserSymptoms(String userId) async {
    final snapshot = await _symptomsCollection
        .where('user_id', isEqualTo: userId)
        .orderBy('logged_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SymptomLogModel.fromFirestore(doc))
        .toList();
  }

  /// Fetch symptoms logged during a specific pregnancy week.
  Future<List<SymptomLogModel>> getSymptomsInWeek({
    required String userId,
    required int week,
  }) async {
    final snapshot = await _symptomsCollection
        .where('user_id', isEqualTo: userId)
        .where('pregnancy_week', isEqualTo: week)
        .orderBy('logged_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SymptomLogModel.fromFirestore(doc))
        .toList();
  }

  /// Fetch symptoms flagged as potential danger signs.
  Future<List<SymptomLogModel>> getFlaggedSymptoms(String userId) async {
    final snapshot = await _symptomsCollection
        .where('user_id', isEqualTo: userId)
        .where('flagged_as_danger', isEqualTo: true)
        .orderBy('logged_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SymptomLogModel.fromFirestore(doc))
        .toList();
  }

  /// Update an existing symptom (e.g. editing the note).
  Future<void> updateSymptom(SymptomLogModel symptom) async {
    await _symptomsCollection
        .doc(symptom.symptomId)
        .update(symptom.toFirestore());
  }

  /// Delete a symptom.
  Future<void> deleteSymptom(String symptomId) async {
    await _symptomsCollection.doc(symptomId).delete();
  }

  /// Real-time stream of a user's symptom history.
  Stream<List<SymptomLogModel>> watchUserSymptoms(String userId) {
    return _symptomsCollection
        .where('user_id', isEqualTo: userId)
        .orderBy('logged_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => SymptomLogModel.fromFirestore(doc))
        .toList());
  }

  // ---------- DANGER CHECKS ----------

  /// Save a completed danger check.
  Future<void> saveDangerCheck(DangerCheckModel check) async {
    if (check.checkId.isNotEmpty) {
      await _dangerChecksCollection
          .doc(check.checkId)
          .set(check.toFirestore());
    } else {
      await _dangerChecksCollection.add(check.toFirestore());
    }
  }

  /// Fetch a user's danger check history, most recent first.
  Future<List<DangerCheckModel>> getUserDangerChecks(String userId) async {
    final snapshot = await _dangerChecksCollection
        .where('user_id', isEqualTo: userId)
        .orderBy('completed_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => DangerCheckModel.fromFirestore(doc))
        .toList();
  }
}