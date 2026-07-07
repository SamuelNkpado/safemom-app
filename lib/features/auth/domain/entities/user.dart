/// Represents a user (expectant mother) in the SafeMom app.
///
/// This is a pure Dart entity — no Firebase, no Flutter dependencies.
/// The data layer converts between this entity and Firestore documents.
///
/// Fields match the `users` collection in the ERD (docs/safemom_erd.png).
class User {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final DateTime dueDate;
  final int currentWeek;
  final String language;
  final String? selectedClinicId;
  final String? partnerUserId;
  final String? profilePhotoUrl;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const User({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.dueDate,
    required this.currentWeek,
    required this.language,
    this.selectedClinicId,
    this.partnerUserId,
    this.profilePhotoUrl,
    required this.createdAt,
    required this.lastActiveAt,
  });

  /// Returns a copy of this User with any fields optionally replaced.
  /// Useful when updating profile info without rebuilding the whole object.
  User copyWith({
    String? userId,
    String? name,
    String? email,
    String? phoneNumber,
    DateTime? dueDate,
    int? currentWeek,
    String? language,
    String? selectedClinicId,
    String? partnerUserId,
    String? profilePhotoUrl,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dueDate: dueDate ?? this.dueDate,
      currentWeek: currentWeek ?? this.currentWeek,
      language: language ?? this.language,
      selectedClinicId: selectedClinicId ?? this.selectedClinicId,
      partnerUserId: partnerUserId ?? this.partnerUserId,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}