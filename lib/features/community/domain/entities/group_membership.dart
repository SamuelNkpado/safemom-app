/// Represents a user's membership in a community group.
///
/// Junction entity resolving the many-to-many relationship between
/// users and community_groups. Tracks whether the user posts
/// anonymously within this specific group.
///
/// Pure Dart entity — no Firebase, no Flutter dependencies.
/// Fields match the `group_memberships` collection in the ERD.
class GroupMembership {
  final String membershipId;
  final String userId;
  final String groupId;
  final bool postsAnonymously;
  final DateTime joinedAt;
  final MembershipRole role;

  const GroupMembership({
    required this.membershipId,
    required this.userId,
    required this.groupId,
    this.postsAnonymously = true,
    required this.joinedAt,
    this.role = MembershipRole.member,
  });

  /// True if this member has moderation privileges in the group.
  bool get isModerator => role == MembershipRole.moderator || role == MembershipRole.admin;

  GroupMembership copyWith({
    String? membershipId,
    String? userId,
    String? groupId,
    bool? postsAnonymously,
    DateTime? joinedAt,
    MembershipRole? role,
  }) {
    return GroupMembership(
      membershipId: membershipId ?? this.membershipId,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      postsAnonymously: postsAnonymously ?? this.postsAnonymously,
      joinedAt: joinedAt ?? this.joinedAt,
      role: role ?? this.role,
    );
  }
}

/// A member's role within a community group.
enum MembershipRole {
  member,
  moderator,
  admin,
}