import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/appointment.dart';
import '../models/appointment_model.dart';

/// Low-level data source that wraps the appointments Firestore
/// collection.
///
/// Handles all Firestore reads, writes, and real-time streams for
/// user appointments.
class AppointmentFirestoreDatasource {
  final FirebaseFirestore _firestore;

  AppointmentFirestoreDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('appointments');

  // ---------- CREATE ----------

  Future<AppointmentModel> scheduleAppointment({
    required String userId,
    required String clinicId,
    required DateTime scheduledAt,
    required VisitType visitType,
    String? notes,
  }) async {
    final data = {
      'user_id': userId,
      'clinic_id': clinicId,
      'scheduled_at': Timestamp.fromDate(scheduledAt),
      'visit_type': _visitTypeToString(visitType),
      'reminder_sent': false,
      'attended': false,
      'notes': notes,
    };

    final docRef = await _collection.add(data);
    final saved = await docRef.get();
    return AppointmentModel.fromFirestore(saved);
  }

  // ---------- READ ----------

  Future<AppointmentModel?> getAppointment(String appointmentId) async {
    final doc = await _collection.doc(appointmentId).get();
    if (!doc.exists) return null;
    return AppointmentModel.fromFirestore(doc);
  }

  Future<List<AppointmentModel>> getUserAppointments(String userId) async {
    final snapshot = await _collection
        .where('user_id', isEqualTo: userId)
        .orderBy('scheduled_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AppointmentModel.fromFirestore(doc))
        .toList();
  }

  /// Upcoming = scheduled in the future AND not yet attended.
  Future<List<AppointmentModel>> getUpcomingAppointments(String userId) async {
    final now = Timestamp.fromDate(DateTime.now());
    final snapshot = await _collection
        .where('user_id', isEqualTo: userId)
        .where('attended', isEqualTo: false)
        .where('scheduled_at', isGreaterThan: now)
        .orderBy('scheduled_at')
        .get();

    return snapshot.docs
        .map((doc) => AppointmentModel.fromFirestore(doc))
        .toList();
  }

  /// Missed = scheduled in the past AND not attended.
  Future<List<AppointmentModel>> getMissedAppointments(String userId) async {
    final now = Timestamp.fromDate(DateTime.now());
    final snapshot = await _collection
        .where('user_id', isEqualTo: userId)
        .where('attended', isEqualTo: false)
        .where('scheduled_at', isLessThan: now)
        .orderBy('scheduled_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AppointmentModel.fromFirestore(doc))
        .toList();
  }

  Stream<List<AppointmentModel>> watchUpcomingAppointments(String userId) {
    final now = Timestamp.fromDate(DateTime.now());
    return _collection
        .where('user_id', isEqualTo: userId)
        .where('attended', isEqualTo: false)
        .where('scheduled_at', isGreaterThan: now)
        .orderBy('scheduled_at')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AppointmentModel.fromFirestore(doc))
        .toList());
  }

  // ---------- UPDATE ----------

  Future<void> markAttended(String appointmentId) async {
    await _collection.doc(appointmentId).update({'attended': true});
  }

  Future<void> reschedule({
    required String appointmentId,
    required DateTime newScheduledAt,
  }) async {
    await _collection.doc(appointmentId).update({
      'scheduled_at': Timestamp.fromDate(newScheduledAt),
      'reminder_sent': false, // reset so the new time gets a fresh reminder
    });
  }

  Future<void> markReminderSent(String appointmentId) async {
    await _collection.doc(appointmentId).update({'reminder_sent': true});
  }

  // ---------- DELETE ----------

  Future<void> deleteAppointment(String appointmentId) async {
    await _collection.doc(appointmentId).delete();
  }

  // ---------- HELPERS ----------

  static String _visitTypeToString(VisitType type) {
    switch (type) {
      case VisitType.antenatalCheckup:
        return 'antenatal_checkup';
      case VisitType.ultrasoundScan:
        return 'ultrasound_scan';
      case VisitType.bloodTest:
        return 'blood_test';
      case VisitType.vaccination:
        return 'vaccination';
      case VisitType.consultation:
        return 'consultation';
      case VisitType.emergency:
        return 'emergency';
      case VisitType.postnatalCheckup:
        return 'postnatal_checkup';
      case VisitType.other:
        return 'other';
    }
  }
}