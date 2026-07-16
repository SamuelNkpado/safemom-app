import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/saved_tip_model.dart';
import '../models/weekly_tip_model.dart';

/// Low-level data source that wraps the weekly_tips and saved_tips
/// Firestore collections.
///
/// Weekly tips are curated content (read-only for users; only admins
/// can write). Saved tips are user-owned bookmarks — full CRUD.
class WeeklyTipFirestoreDatasource {
  final FirebaseFirestore _firestore;

  WeeklyTipFirestoreDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _weeklyTipsCollection =>
      _firestore.collection('weekly_tips');

  CollectionReference<Map<String, dynamic>> get _savedTipsCollection =>
      _firestore.collection('saved_tips');

  // ---------- WEEKLY TIPS (read-only) ----------

  /// Fetch the tip for a specific pregnancy week in the given language.
  ///
  /// Returns null if no tip exists.
  Future<WeeklyTipModel?> getTipForWeek({
    required int week,
    required String languageCode,
  }) async {
    final snapshot = await _weeklyTipsCollection
        .where('week_number', isEqualTo: week)
        .where('language_code', isEqualTo: languageCode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return WeeklyTipModel.fromFirestore(snapshot.docs.first);
  }

  /// Fetch tips across a week range in the given language.
  Future<List<WeeklyTipModel>> getTipsForRange({
    required int startWeek,
    required int endWeek,
    required String languageCode,
  }) async {
    final snapshot = await _weeklyTipsCollection
        .where('language_code', isEqualTo: languageCode)
        .where('week_number', isGreaterThanOrEqualTo: startWeek)
        .where('week_number', isLessThanOrEqualTo: endWeek)
        .orderBy('week_number')
        .get();

    return snapshot.docs
        .map((doc) => WeeklyTipModel.fromFirestore(doc))
        .toList();
  }

  // ---------- SAVED TIPS (user-owned) ----------

  /// Save a tip for a user. Returns the existing saved tip if the user
  /// has already bookmarked this tip (idempotent).
  Future<SavedTipModel> saveTip({
    required String userId,
    required String tipId,
    String? note,
  }) async {
    // Check if already saved
    final existing = await _savedTipsCollection
        .where('user_id', isEqualTo: userId)
        .where('tip_id', isEqualTo: tipId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return SavedTipModel.fromFirestore(existing.docs.first);
    }

    // Create new saved tip
    final now = DateTime.now();
    final data = {
      'user_id': userId,
      'tip_id': tipId,
      'saved_at': Timestamp.fromDate(now),
      'note': note,
    };

    final docRef = await _savedTipsCollection.add(data);

    return SavedTipModel(
      savedId: docRef.id,
      userId: userId,
      tipId: tipId,
      savedAt: now,
      note: note,
    );
  }

  /// Fetch a user's saved tips, most recent first.
  Future<List<SavedTipModel>> getUserSavedTips(String userId) async {
    final snapshot = await _savedTipsCollection
        .where('user_id', isEqualTo: userId)
        .orderBy('saved_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SavedTipModel.fromFirestore(doc))
        .toList();
  }

  /// Delete a saved tip.
  Future<void> unsaveTip(String savedId) async {
    await _savedTipsCollection.doc(savedId).delete();
  }

  /// Check whether a user has already saved a specific tip.
  Future<bool> hasSavedTip({
    required String userId,
    required String tipId,
  }) async {
    final snapshot = await _savedTipsCollection
        .where('user_id', isEqualTo: userId)
        .where('tip_id', isEqualTo: tipId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}