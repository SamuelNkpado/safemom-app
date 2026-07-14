import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

/// Low-level data source that wraps Firebase Auth, Google Sign-In,
/// and the users Firestore collection.
///
/// This is the ONLY class in the auth feature that imports Firebase.
/// Everything above it (repository implementation, use cases, UI) talks
/// to this class or to the interface it fulfils — never to Firebase
/// directly.
class FirebaseAuthDatasource {
  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  FirebaseAuthDatasource({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Currently signed-in Firebase user, or null if no session.
  fb.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Stream that emits whenever auth state changes.
  Stream<fb.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ---------- EMAIL / PASSWORD ----------

  /// Create a new Firebase Auth account AND write the user profile
  /// to Firestore.
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required DateTime dueDate,
  }) async {
    // Step 1: create the auth record
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw fb.FirebaseAuthException(
        code: 'null-user',
        message: 'Firebase returned no user after sign-up.',
      );
    }

    // Step 2: send verification email (best-effort, don't block sign-up)
    try {
      await firebaseUser.sendEmailVerification();
    } catch (_) {
      // Non-fatal; user can request it again later.
    }

    // Step 3: compute pregnancy week from due date
    final now = DateTime.now();
    final daysUntilDue = dueDate.difference(now).inDays;
    final currentWeek = 40 - (daysUntilDue ~/ 7);
    final safeWeek = currentWeek.clamp(1, 45);

    // Step 4: create the users/{uid} Firestore document
    final userModel = UserModel(
      userId: firebaseUser.uid,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      dueDate: dueDate,
      currentWeek: safeWeek,
      language: 'en',
      selectedClinicId: null,
      partnerUserId: null,
      profilePhotoUrl: null,
      createdAt: now,
      lastActiveAt: now,
    );

    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(userModel.toFirestore());

    return userModel;
  }

  /// Sign in an existing user and fetch their profile from Firestore.
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw fb.FirebaseAuthException(
        code: 'null-user',
        message: 'Firebase returned no user after sign-in.',
      );
    }

    // Update lastActiveAt on the profile
    await _firestore.collection('users').doc(firebaseUser.uid).update({
      'last_active_at': Timestamp.fromDate(DateTime.now()),
    });

    return _fetchUserProfile(firebaseUser.uid);
  }

  // ---------- GOOGLE SIGN-IN ----------

  /// Sign in with Google. Creates a Firestore user profile on first
  /// sign-in; loads the existing one otherwise.
  Future<UserModel> signInWithGoogle() async {
    // Step 1: run the Google Sign-In flow
    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;

    // Step 2: convert Google credentials to Firebase credentials
    final credential = fb.GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    // Step 3: sign in to Firebase with those credentials
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;

    if (firebaseUser == null) {
      throw fb.FirebaseAuthException(
        code: 'null-user',
        message: 'Firebase returned no user after Google sign-in.',
      );
    }

    // Step 4: check if a Firestore profile already exists
    final docRef = _firestore.collection('users').doc(firebaseUser.uid);
    final existing = await docRef.get();

    if (existing.exists) {
      // Returning user — just update lastActiveAt
      await docRef.update({
        'last_active_at': Timestamp.fromDate(DateTime.now()),
      });
      return UserModel.fromFirestore(existing);
    }

    // First-time Google sign-in — create minimal profile.
    // Onboarding flow will collect due date, phone, etc.
    final now = DateTime.now();
    final newProfile = UserModel(
      userId: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      phoneNumber: firebaseUser.phoneNumber ?? '',
      dueDate: now, // placeholder; onboarding will overwrite
      currentWeek: 1,
      language: 'en',
      selectedClinicId: null,
      partnerUserId: null,
      profilePhotoUrl: firebaseUser.photoURL,
      createdAt: now,
      lastActiveAt: now,
    );

    await docRef.set(newProfile.toFirestore());
    return newProfile;
  }

  // ---------- PROFILE FETCH ----------

  /// Fetch the users/{uid} profile document.
  Future<UserModel> _fetchUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw fb.FirebaseAuthException(
        code: 'profile-missing',
        message: 'User is authenticated but has no profile document.',
      );
    }
    return UserModel.fromFirestore(doc);
  }

  Future<UserModel?> fetchCurrentUserProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return _fetchUserProfile(user.uid);
  }

  // ---------- EMAIL VERIFICATION & PASSWORD RESET ----------

  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // ---------- SIGN OUT ----------

  Future<void> signOut() async {
    // Sign out of Google if we're signed in there
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Non-fatal
    }
    await _firebaseAuth.signOut();
  }

  // ---------- ACCOUNT DELETION ----------

  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    // Note: this only deletes the auth record.
    // The user's Firestore documents are handled by a separate cleanup path.
    await user.delete();
  }
}