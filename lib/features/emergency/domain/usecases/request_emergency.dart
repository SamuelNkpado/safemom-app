import '../entities/emergency_request.dart';
import '../repositories/emergency_repository.dart';
/// Business operation: initiate an emergency dispatch request.
///
/// This is the highest-stakes operation in the app. When the user taps
/// the SOS button, this use case is called immediately.
///
/// Rules enforced here:
/// - The user must have a selected clinic (chosen during onboarding)
/// - GPS coordinates must be present and within valid ranges
/// - The user cannot have another active emergency in progress
///   (prevents accidental duplicate dispatches)
///
/// The repository implementation handles the actual dispatch call to
/// the partner ambulance service and notifies the user's linked partner.
class RequestEmergency {
  final EmergencyRepository repository;

  RequestEmergency(this.repository);

  /// Executes the emergency request flow.
  ///
  /// Throws [ArgumentError] on invalid input.
  /// Throws [StateError] if the user already has an active emergency.
  /// Throws [EmergencyException] if dispatch fails at the provider level —
  /// the presentation layer must always surface a fallback (direct
  /// clinic phone call) if this happens.
  Future<EmergencyRequest> call({
    required String userId,
    required String clinicId,
    required double latitude,
    required double longitude,
  }) async {
    // ---------- VALIDATION ----------

    if (userId.trim().isEmpty) {
      throw ArgumentError('User must be signed in to request emergency help.');
    }

    if (clinicId.trim().isEmpty) {
      throw ArgumentError(
        'A clinic must be selected before emergency dispatch. '
            'Please complete onboarding first.',
      );
    }

    if (latitude < -90 || latitude > 90) {
      throw ArgumentError('Latitude must be between -90 and 90.');
    }

    if (longitude < -180 || longitude > 180) {
      throw ArgumentError('Longitude must be between -180 and 180.');
    }

    // ---------- DUPLICATE-REQUEST GUARD ----------

    final active = await repository.getActiveRequest(userId);
    if (active != null) {
      throw StateError(
        'You already have an active emergency request in progress. '
            'Cancel the current one before requesting a new dispatch.',
      );
    }

    // ---------- DISPATCH ----------

    return repository.createRequest(
      userId: userId,
      clinicId: clinicId,
      latitude: latitude,
      longitude: longitude,
    );
  }
}