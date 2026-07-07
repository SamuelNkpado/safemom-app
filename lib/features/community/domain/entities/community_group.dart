/// Represents a community group of expectant or new mothers.
///
/// Groups filter members by pregnancy stage and/or geographic location.
///
/// Pure Dart entity — no Firebase, no Flutter dependencies.
/// Fields match the `community_groups` collection in the ERD.
class CommunityGroup {
  final String groupId;
  final String name;
  final String description;
  final PregnancyStageFilter? pregnancyStageFilter;
  final String? locationFilter;
  final int memberCount;
  final DateTime createdAt;
  final bool isPrivate;

  const CommunityGroup({
    required this.groupId,
    required this.name,
    required this.description,
    this.pregnancyStageFilter,
    this.locationFilter,
    this.memberCount = 0,
    required this.createdAt,
    this.isPrivate = false,
  });

  /// True if this group has no eligibility restrictions.
  bool get isOpen => pregnancyStageFilter == null && locationFilter == null;

  CommunityGroup copyWith({
    String? groupId,
    String? name,
    String? description,
    PregnancyStageFilter? pregnancyStageFilter,
    String? locationFilter,
    int? memberCount,
    DateTime? createdAt,
    bool? isPrivate,
  }) {
    return CommunityGroup(
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      pregnancyStageFilter: pregnancyStageFilter ?? this.pregnancyStageFilter,
      locationFilter: locationFilter ?? this.locationFilter,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}

/// Pregnancy stage filter used to segment community groups.
enum PregnancyStageFilter {
  firstTrimester,
  secondTrimester,
  thirdTrimester,
  postpartum,
  tryingToConceive,
  partners,
}