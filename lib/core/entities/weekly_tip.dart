/// Represents a piece of educational content shown to users based on
/// their current pregnancy week.
///
/// Weekly tips are curated content (not user-generated) and are
/// localised into Kiswahili and English.
///
/// Pure Dart entity — no Firebase, no Flutter dependencies.
/// Fields match the `weekly_tips` collection in the ERD.
class WeeklyTip {
  final String tipId;
  final int weekNumber; // 1 through 40
  final String title;
  final String body;
  final TipCategory category;
  final String languageCode; // 'en' or 'sw'
  final String? imageUrl;
  final int estimatedReadMinutes;

  const WeeklyTip({
    required this.tipId,
    required this.weekNumber,
    required this.title,
    required this.body,
    required this.category,
    required this.languageCode,
    this.imageUrl,
    this.estimatedReadMinutes = 3,
  });

  /// True if this tip is written in Kiswahili.
  bool get isSwahili => languageCode == 'sw';

  WeeklyTip copyWith({
    String? tipId,
    int? weekNumber,
    String? title,
    String? body,
    TipCategory? category,
    String? languageCode,
    String? imageUrl,
    int? estimatedReadMinutes,
  }) {
    return WeeklyTip(
      tipId: tipId ?? this.tipId,
      weekNumber: weekNumber ?? this.weekNumber,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      languageCode: languageCode ?? this.languageCode,
      imageUrl: imageUrl ?? this.imageUrl,
      estimatedReadMinutes: estimatedReadMinutes ?? this.estimatedReadMinutes,
    );
  }
}

/// Category classification for weekly tips.
enum TipCategory {
  nutrition,
  physicalHealth,
  mentalHealth,
  babyDevelopment,
  laborAndDelivery,
  postpartum,
  partnerInvolvement,
  emergencyAwareness,
  clinicalCare,
}