import '../repositories/community_repository.dart';

/// Business operation: leave a community group.
///
/// Rules enforced:
/// - user must be signed in
/// - membership ID must be provided
/// - the membership must belong to the user (also enforced by Firestore
///   security rules, but we check here so we can throw a friendly error
///   before touching Firestore)
class LeaveGroup {
  final CommunityRepository repository;

  LeaveGroup(this.repository);

  /// Executes the leave-group flow.
  ///
  /// Throws [ArgumentError] on invalid input.
  /// Throws [StateError] if the membership does not belong to the user.
  /// Throws [CommunityException] if the delete fails.
  Future<void> call({
    required String userId,
    required String membershipId,
  }) async {
    // ---------- VALIDATION ----------

    if (userId.trim().isEmpty) {
      throw ArgumentError('User must be signed in to leave a group.');
    }

    if (membershipId.trim().isEmpty) {
      throw ArgumentError('Membership ID is required.');
    }

    // ---------- OWNERSHIP GUARD ----------

    final memberships = await repository.getUserMemberships(userId);
    final ownsMembership = memberships.any((m) => m.membershipId == membershipId);

    if (!ownsMembership) {
      throw StateError(
        'You can only leave groups you have joined.',
      );
    }

    // ---------- LEAVE ----------

    return repository.leaveGroup(membershipId);
  }
}