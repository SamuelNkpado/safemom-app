import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

/// Business operation: fetch the user's upcoming (future, unattended)
/// appointments.
///
/// Used primarily by the home dashboard to show the next visit reminder.
/// Returns the appointments sorted soonest first.
class GetUpcomingAppointments {
  final AppointmentRepository repository;

  GetUpcomingAppointments(this.repository);

  /// Executes the fetch.
  ///
  /// [limit] optionally caps how many appointments are returned.
  /// Defaults to all upcoming appointments.
  ///
  /// Throws [ArgumentError] if userId is empty.
  Future<List<Appointment>> call({
    required String userId,
    int? limit,
  }) async {
    // ---------- VALIDATION ----------

    if (userId.trim().isEmpty) {
      throw ArgumentError('You must be signed in to view appointments.');
    }

    if (limit != null && limit < 1) {
      throw ArgumentError('Limit must be at least 1.');
    }

    // ---------- FETCH ----------

    final appointments = await repository.getUpcomingAppointments(userId);

    // ---------- SORT SOONEST FIRST ----------

    appointments.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    // ---------- APPLY LIMIT ----------

    if (limit != null && appointments.length > limit) {
      return appointments.sublist(0, limit);
    }

    return appointments;
  }
}