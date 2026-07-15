import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/group_membership.dart';

/// Data model for the GroupMembership entity.
///
/// Junction between users and community groups. Extends the pure entity
/// with Firestore serialisation logic.
class GroupMembershipModel extends GroupMembership {
  const GroupMembershipModel({
    required super.membershipId,
    required super.userId,
    required super.groupId,
    super.postsAnonymously,
    required super.joinedAt,
    super.role,
  });

  factory GroupMembershipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return GroupMembershipModel(
      membershipId: doc.id,
      userId: data['user_id'] as String? ?? '',
      groupId: data['group_id'] as String? ?? '',
      postsAnonymously: data['posts_anonymously'] as bool? ?? true,
      joinedAt: _timestampToDateTime(data['joined_at']) ?? DateTime.now(),
      role: _roleFromString(data['role'] as String?),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'group_id': groupId,
      'posts_anonymously': postsAnonymously,
      'joined_at': Timestamp.fromDate(joinedAt),
      'role': _roleToString(role),
    };
  }

  factory GroupMembershipModel.fromEntity(GroupMembership membership) {
    return GroupMembershipModel(
      membershipId: membership.membershipId,
      userId: membership.userId,
      groupId: membership.groupId,
      postsAnonymously: membership.postsAnonymously,
      joinedAt: membership.joinedAt,
      role: membership.role,
    );
  }

  // ---------- ENUM SERIALISATION ----------

  static MembershipRole _roleFromString(String? value) {
    switch (value) {
      case 'moderator':
        return MembershipRole.moderator;
      case 'admin':
        return MembershipRole.admin;
      case 'member':
      default:
        return MembershipRole.member;
    }
  }

  static String _roleToString(MembershipRole role) {
    switch (role) {
      case MembershipRole.member:
        return 'member';
      case MembershipRole.moderator:
        return 'moderator';
      case MembershipRole.admin:
        return 'admin';
    }
  }

  // ---------- TIMESTAMP HELPER ----------

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}