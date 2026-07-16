import '../entities/group_membership.dart';
import '../repositories/community_repository.dart';

/// Business operation: join a community group.
///
/// Enforces business rules:
/// - user must be signed in
/// - group ID must be provided
/// - user cannot join the same group twice (verified by checking
///   existing memberships)
///
/// The repository handles the actual Firestore write.
class JoinGroup {
  final CommunityRepository repository;

  JoinGroup(this.repository);

  /// Executes the join-group flow.
  ///
  /// Throws [ArgumentError] on invalid input.
  /// Throws [StateError] if the user is already a member of this group.
  /// Throws [CommunityException] if persistence fails.
  Future<GroupMembership> call({
    required String userId,
    required String groupId,
    bool postsAnonymously = true,
  }) async {
    // ---------- VALIDATION ----------

    if (userId.trim().isEmpty) {
      throw ArgumentError('User must be signed in to join a group.');
    }

    if (groupId.trim().isEmpty) {
      throw ArgumentError('Group ID is required.');
    }

    // ---------- DUPLICATE-MEMBERSHIP GUARD ----------

    final existing = await repository.getUserMemberships(userId);
    final alreadyMember = existing.any((m) => m.groupId == groupId);

    if (alreadyMember) {
      throw StateError('You are already a member of this group.');
    }

    // ---------- JOIN ----------

    return repository.joinGroup(
      userId: userId,
      groupId: groupId,
      postsAnonymously: postsAnonymously,
    );
  }
}