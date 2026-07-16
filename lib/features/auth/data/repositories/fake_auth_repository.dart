import 'dart:async';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// TEMPORARY DEV STUB — in-memory implementation of [AuthRepository].
///
/// This lets the frontend build and run the auth UI before the Firebase
/// data layer exists. It is NOT wired to any backend: sign-up/sign-in just
/// fabricate a [User] and push it onto the auth stream.
///
/// BACKEND TEAM: replace this with `FirebaseAuthRepository` (firebase_auth +
/// google_sign_in + a Firestore user document) and delete this file. The DI
/// in `lib/core/di/auth_locator.dart` is the only place that references it.
class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<User?>.broadcast();
  User? _current;

  @override
  User? get currentUser => _current;

  @override
  Stream<User?> get authStateChanges async* {
    yield _current;
    yield* _controller.stream;
  }

  void _emit(User? user) {
    _current = user;
    _controller.add(user);
  }

  User _fabricate({
    required String name,
    required String email,
    required String phoneNumber,
    required DateTime dueDate,
  }) {
    final now = DateTime.now();
    final daysToDue = dueDate.difference(now).inDays;
    final week = (40 - (daysToDue / 7)).round().clamp(1, 42);
    return User(
      userId: 'dev-${now.millisecondsSinceEpoch}',
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      dueDate: dueDate,
      currentWeek: week,
      language: 'en',
      createdAt: now,
      lastActiveAt: now,
    );
  }

  @override
  Future<User> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required DateTime dueDate,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final user = _fabricate(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      dueDate: dueDate,
    );
    _emit(user);
    return user;
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    // Dev-only rule: any well-formed credentials "work".
    final user = _fabricate(
      name: 'Amina W.',
      email: email,
      phoneNumber: '+254712345678',
      dueDate: DateTime.now().add(const Duration(days: 112)),
    );
    _emit(user);
    return user;
  }

  @override
  Future<User> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final user = _fabricate(
      name: 'Google Mama',
      email: 'mama@gmail.com',
      phoneNumber: '+254700000000',
      dueDate: DateTime.now().add(const Duration(days: 140)),
    );
    _emit(user);
    return user;
  }

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> resetPassword(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _emit(null);
  }

  @override
  Future<void> deleteAccount() async {
    _emit(null);
  }

  void dispose() => _controller.close();
}
