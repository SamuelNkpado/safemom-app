import '../entities/appointment.dart';

/// Contract for appointment operations.
///
/// The data layer implements this using Firestore. Appointments are
/// user-owned and reference the clinic where they take place.
abstract class AppointmentRepository {
  /// Create a new appointment for the current user.
  Future<Appointment> scheduleAppointment({
    required String userId,
    required String clinicId,
    required DateTime scheduledAt,
    required VisitType visitType,
    String? notes,
  });

  /// Fetch a single appointment by ID.
  Future<Appointment?> getAppointment(String appointmentId);

  /// Fetch all appointments for a user, most recent first.
  Future<List<Appointment>> getUserAppointments(String userId);

  /// Fetch only upcoming (unattended, future) appointments.
  ///
  /// Used by the home dashboard reminder card.
  Future<List<Appointment>> getUpcomingAppointments(String userId);

  /// Fetch appointments that were missed (past date, not attended).
  Future<List<Appointment>> getMissedAppointments(String userId);

  /// Mark an appointment as attended.
  Future<void> markAttended(String appointmentId);

  /// Reschedule an existing appointment.
  Future<void> reschedule({
    required String appointmentId,
    required DateTime newScheduledAt,
  });

  /// Delete an appointment.
  Future<void> deleteAppointment(String appointmentId);

  /// Mark that a reminder has been sent for this appointment.
  ///
  /// Used to prevent duplicate notifications.
  Future<void> markReminderSent(String appointmentId);

  /// Real-time stream of a user's upcoming appointments.
  Stream<List<Appointment>> watchUpcomingAppointments(String userId);
}

/// Base exception for appointment operations.
class AppointmentException implements Exception {
  final String message;
  final String? code;

  const AppointmentException(this.message, {this.code});

  @override
  String toString() => 'AppointmentException($code): $message';
}