import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/entities/weekly_tip.dart';

/// Data model for the WeeklyTip entity.
///
/// Extends the pure entity with Firestore serialisation logic.
/// Weekly tips are curated content — admin-written pregnancy education
/// segmented by week and language.
class WeeklyTipModel extends WeeklyTip {
  const WeeklyTipModel({
    required super.tipId,
    required super.weekNumber,
    required super.title,
    required super.body,
    required super.category,
    required super.languageCode,
    super.imageUrl,
    super.estimatedReadMinutes,
  });

  factory WeeklyTipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return WeeklyTipModel(
      tipId: doc.id,
      weekNumber: (data['week_number'] as num?)?.toInt() ?? 1,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      category: _categoryFromString(data['category'] as String?),
      languageCode: data['language_code'] as String? ?? 'en',
      imageUrl: data['image_url'] as String?,
      estimatedReadMinutes:
      (data['estimated_read_minutes'] as num?)?.toInt() ?? 3,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'week_number': weekNumber,
      'title': title,
      'body': body,
      'category': _categoryToString(category),
      'language_code': languageCode,
      'image_url': imageUrl,
      'estimated_read_minutes': estimatedReadMinutes,
    };
  }

  factory WeeklyTipModel.fromEntity(WeeklyTip tip) {
    return WeeklyTipModel(
      tipId: tip.tipId,
      weekNumber: tip.weekNumber,
      title: tip.title,
      body: tip.body,
      category: tip.category,
      languageCode: tip.languageCode,
      imageUrl: tip.imageUrl,
      estimatedReadMinutes: tip.estimatedReadMinutes,
    );
  }

  // ---------- ENUM SERIALISATION ----------

  static TipCategory _categoryFromString(String? value) {
    switch (value) {
      case 'nutrition':
        return TipCategory.nutrition;
      case 'physical_health':
        return TipCategory.physicalHealth;
      case 'mental_health':
        return TipCategory.mentalHealth;
      case 'baby_development':
        return TipCategory.babyDevelopment;
      case 'labor_and_delivery':
        return TipCategory.laborAndDelivery;
      case 'postpartum':
        return TipCategory.postpartum;
      case 'partner_involvement':
        return TipCategory.partnerInvolvement;
      case 'emergency_awareness':
        return TipCategory.emergencyAwareness;
      case 'clinical_care':
        return TipCategory.clinicalCare;
      default:
        return TipCategory.nutrition;
    }
  }

  static String _categoryToString(TipCategory category) {
    switch (category) {
      case TipCategory.nutrition:
        return 'nutrition';
      case TipCategory.physicalHealth:
        return 'physical_health';
      case TipCategory.mentalHealth:
        return 'mental_health';
      case TipCategory.babyDevelopment:
        return 'baby_development';
      case TipCategory.laborAndDelivery:
        return 'labor_and_delivery';
      case TipCategory.postpartum:
        return 'postpartum';
      case TipCategory.partnerInvolvement:
        return 'partner_involvement';
      case TipCategory.emergencyAwareness:
        return 'emergency_awareness';
      case TipCategory.clinicalCare:
        return 'clinical_care';
    }
  }
}