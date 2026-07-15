import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/community_group.dart';

/// Data model for the CommunityGroup entity.
///
/// Extends the pure entity with Firestore serialisation logic.
class CommunityGroupModel extends CommunityGroup {
  const CommunityGroupModel({
    required super.groupId,
    required super.name,
    required super.description,
    super.pregnancyStageFilter,
    super.locationFilter,
    super.memberCount,
    required super.createdAt,
    super.isPrivate,
  });

  factory CommunityGroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return CommunityGroupModel(
      groupId: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      pregnancyStageFilter: _stageFromString(
        data['pregnancy_stage_filter'] as String?,
      ),
      locationFilter: data['location_filter'] as String?,
      memberCount: (data['member_count'] as num?)?.toInt() ?? 0,
      createdAt: _timestampToDateTime(data['created_at']) ?? DateTime.now(),
      isPrivate: data['is_private'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'pregnancy_stage_filter': pregnancyStageFilter != null
          ? _stageToString(pregnancyStageFilter!)
          : null,
      'location_filter': locationFilter,
      'member_count': memberCount,
      'created_at': Timestamp.fromDate(createdAt),
      'is_private': isPrivate,
    };
  }

  factory CommunityGroupModel.fromEntity(CommunityGroup group) {
    return CommunityGroupModel(
      groupId: group.groupId,
      name: group.name,
      description: group.description,
      pregnancyStageFilter: group.pregnancyStageFilter,
      locationFilter: group.locationFilter,
      memberCount: group.memberCount,
      createdAt: group.createdAt,
      isPrivate: group.isPrivate,
    );
  }

  // ---------- ENUM SERIALISATION ----------

  static PregnancyStageFilter? _stageFromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'first_trimester':
        return PregnancyStageFilter.firstTrimester;
      case 'second_trimester':
        return PregnancyStageFilter.secondTrimester;
      case 'third_trimester':
        return PregnancyStageFilter.thirdTrimester;
      case 'postpartum':
        return PregnancyStageFilter.postpartum;
      case 'trying_to_conceive':
        return PregnancyStageFilter.tryingToConceive;
      case 'partners':
        return PregnancyStageFilter.partners;
      default:
        return null;
    }
  }

  static String _stageToString(PregnancyStageFilter stage) {
    switch (stage) {
      case PregnancyStageFilter.firstTrimester:
        return 'first_trimester';
      case PregnancyStageFilter.secondTrimester:
        return 'second_trimester';
      case PregnancyStageFilter.thirdTrimester:
        return 'third_trimester';
      case PregnancyStageFilter.postpartum:
        return 'postpartum';
      case PregnancyStageFilter.tryingToConceive:
        return 'trying_to_conceive';
      case PregnancyStageFilter.partners:
        return 'partners';
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