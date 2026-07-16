import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_firestore_datasource.dart';

/// Concrete implementation of [AppointmentRepository] backed by Firestore.
///
/// Delegates to the datasource and translates Firebase-specific
/// exceptions into domain-level [AppointmentException]s.
class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentFirestoreDatasource _datasource;

  AppointmentRepositoryImpl(this._datasource);

  // ---------- CREATE ----------

  @override
  Future<Appointment> scheduleAppointment({
    required String userId,
    required String clinicId,
    required DateTime scheduledAt,
    required VisitType visitType,
    String? notes,
  }) async {
    try {
      return await _datasource.scheduleAppointment(
        userId: userId,
        clinicId: clinicId,
        scheduledAt: scheduledAt,
        visitType: visitType,
        notes: notes,
      );
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- READ ----------

  @override
  Future<Appointment?> getAppointment(String appointmentId) async {
    try {
      return await _datasource.getAppointment(appointmentId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<List<Appointment>> getUserAppointments(String userId) async {
    try {
      return await _datasource.getUserAppointments(userId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<List<Appointment>> getUpcomingAppointments(String userId) async {
    try {
      return await _datasource.getUpcomingAppointments(userId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<List<Appointment>> getMissedAppointments(String userId) async {
    try {
      return await _datasource.getMissedAppointments(userId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Stream<List<Appointment>> watchUpcomingAppointments(String userId) {
    return _datasource.watchUpcomingAppointments(userId);
  }

  // ---------- UPDATE ----------

  @override
  Future<void> markAttended(String appointmentId) async {
    try {
      await _datasource.markAttended(appointmentId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<void> reschedule({
    required String appointmentId,
    required DateTime newScheduledAt,
  }) async {
    try {
      await _datasource.reschedule(
        appointmentId: appointmentId,
        newScheduledAt: newScheduledAt,
      );
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<void> markReminderSent(String appointmentId) async {
    try {
      await _datasource.markReminderSent(appointmentId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- DELETE ----------

  @override
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _datasource.deleteAppointment(appointmentId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- ERROR TRANSLATION ----------

  AppointmentException _translateException(FirebaseException e) {
    final code = e.code;
    switch (code) {
      case 'permission-denied':
        return const AppointmentException(
          'You do not have permission for this action. '
              'Please sign in again.',
          code: 'permission-denied',
        );
      case 'unavailable':
      case 'deadline-exceeded':
        return const AppointmentException(
          'Could not reach the server. Please check your connection.',
          code: 'service-unavailable',
        );
      case 'not-found':
        return const AppointmentException(
          'This appointment could not be found.',
          code: 'not-found',
        );
      case 'network-request-failed':
        return const AppointmentException(
          'No internet connection.',
          code: 'network-error',
        );
      default:
        return AppointmentException(
          e.message ?? 'Something went wrong. Please try again.',
          code: code,
        );
    }
  }
}