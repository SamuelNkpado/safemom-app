import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

/// Business operation: schedule a new appointment for the user.
///
/// Rules enforced:
/// - user must be signed in
/// - clinic must be provided
/// - scheduled time must be in the future
/// - scheduled time cannot be more than 12 months out (data-quality guard)
/// - notes have a length limit
class ScheduleAppointment {
  final AppointmentRepository repository;

  ScheduleAppointment(this.repository);

  /// Executes the schedule flow.
  ///
  /// Throws [ArgumentError] on invalid input.
  /// Throws [AppointmentException] if persistence fails.
  Future<Appointment> call({
    required String userId,
    required String clinicId,
    required DateTime scheduledAt,
    required VisitType visitType,
    String? notes,
  }) async {
    // ---------- VALIDATION ----------

    if (userId.trim().isEmpty) {
      throw ArgumentError('You must be signed in to schedule appointments.');
    }

    if (clinicId.trim().isEmpty) {
      throw ArgumentError('Clinic is required.');
    }

    final now = DateTime.now();

    if (scheduledAt.isBefore(now)) {
      throw ArgumentError('Appointment time must be in the future.');
    }

    final maxScheduleDate = now.add(const Duration(days: 365));
    if (scheduledAt.isAfter(maxScheduleDate)) {
      throw ArgumentError(
        'Appointment cannot be scheduled more than 12 months in advance.',
      );
    }

    if (notes != null && notes.length > 300) {
      throw ArgumentError('Notes must be under 300 characters.');
    }

    // ---------- CREATE ----------

    return repository.scheduleAppointment(
      userId: userId,
      clinicId: clinicId,
      scheduledAt: scheduledAt,
      visitType: visitType,
      notes: notes?.trim(),
    );
  }
}