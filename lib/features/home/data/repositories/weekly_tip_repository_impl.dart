import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/entities/saved_tip.dart';
import '../../../../core/entities/weekly_tip.dart';
import '../../domain/repositories/weekly_tip_repository.dart';
import '../datasources/weekly_tip_firestore_datasource.dart';

/// Concrete implementation of [WeeklyTipRepository] backed by Firestore.
///
/// Delegates to the datasource and translates Firebase-specific
/// exceptions into domain-level [WeeklyTipException]s.
class WeeklyTipRepositoryImpl implements WeeklyTipRepository {
  final WeeklyTipFirestoreDatasource _datasource;

  WeeklyTipRepositoryImpl(this._datasource);

  // ---------- WEEKLY TIPS ----------

  @override
  Future<WeeklyTip?> getTipForWeek({
    required int week,
    required String languageCode,
  }) async {
    try {
      return await _datasource.getTipForWeek(
        week: week,
        languageCode: languageCode,
      );
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<List<WeeklyTip>> getTipsForRange({
    required int startWeek,
    required int endWeek,
    required String languageCode,
  }) async {
    try {
      return await _datasource.getTipsForRange(
        startWeek: startWeek,
        endWeek: endWeek,
        languageCode: languageCode,
      );
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- SAVED TIPS ----------

  @override
  Future<SavedTip> saveTip({
    required String userId,
    required String tipId,
    String? note,
  }) async {
    try {
      return await _datasource.saveTip(
        userId: userId,
        tipId: tipId,
        note: note,
      );
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<List<SavedTip>> getUserSavedTips(String userId) async {
    try {
      return await _datasource.getUserSavedTips(userId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<void> unsaveTip(String savedId) async {
    try {
      await _datasource.unsaveTip(savedId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<bool> hasSavedTip({
    required String userId,
    required String tipId,
  }) async {
    try {
      return await _datasource.hasSavedTip(userId: userId, tipId: tipId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- ERROR TRANSLATION ----------

  WeeklyTipException _translateException(FirebaseException e) {
    final code = e.code;
    switch (code) {
      case 'permission-denied':
        return const WeeklyTipException(
          'You do not have permission for this action. '
              'Please sign in again.',
          code: 'permission-denied',
        );
      case 'unavailable':
      case 'deadline-exceeded':
        return const WeeklyTipException(
          'Could not reach the server. Please check your connection.',
          code: 'service-unavailable',
        );
      case 'not-found':
        return const WeeklyTipException(
          'This tip could not be found.',
          code: 'not-found',
        );
      case 'network-request-failed':
        return const WeeklyTipException(
          'No internet connection.',
          code: 'network-error',
        );
      default:
        return WeeklyTipException(
          e.message ?? 'Something went wrong. Please try again.',
          code: code,
        );
    }
  }
}