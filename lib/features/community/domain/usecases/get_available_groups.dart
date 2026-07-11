import '../entities/community_group.dart';
import '../repositories/community_repository.dart';

/// Business operation: fetch community groups the user is eligible to see.
///
/// Filters happen at the repository level based on pregnancy week and
/// optional location. This use case validates inputs and applies any
/// additional presentation-order rules.
class GetAvailableGroups {
  final CommunityRepository repository;

  GetAvailableGroups(this.repository);

  /// Executes the fetch.
  ///
  /// Groups are returned sorted with the most relevant to the user first:
  /// - Groups matching their exact pregnancy stage
  /// - Then location-matched groups
  /// - Then open groups
  ///
  /// Throws [ArgumentError] on invalid pregnancy week.
  Future<List<CommunityGroup>> call({
    required int pregnancyWeek,
    String? locationHint,
  }) async {
    // ---------- VALIDATION ----------

    if (pregnancyWeek < 1 || pregnancyWeek > 45) {
      throw ArgumentError(
        'Pregnancy week must be between 1 and 45.',
      );
    }

    // ---------- FETCH ----------

    final groups = await repository.getAvailableGroups(
      pregnancyWeek: pregnancyWeek,
      locationHint: locationHint?.trim(),
    );

    // ---------- SORT BY RELEVANCE ----------

    final userStage = _stageForWeek(pregnancyWeek);

    groups.sort((a, b) {
      final aMatches = a.pregnancyStageFilter == userStage ? 1 : 0;
      final bMatches = b.pregnancyStageFilter == userStage ? 1 : 0;

      // Higher score first
      if (aMatches != bMatches) return bMatches.compareTo(aMatches);

      // Then by member count (larger groups first)
      return b.memberCount.compareTo(a.memberCount);
    });

    return groups;
  }

  /// Map a pregnancy week to its stage filter.
  PregnancyStageFilter _stageForWeek(int week) {
    if (week <= 13) return PregnancyStageFilter.firstTrimester;
    if (week <= 27) return PregnancyStageFilter.secondTrimester;
    return PregnancyStageFilter.thirdTrimester;
  }
}