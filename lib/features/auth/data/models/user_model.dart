import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

/// Data model for the User entity.
///
/// Extends the pure User entity with Firestore serialisation logic.
/// This is the only User-related class that knows about Firestore —
/// the domain layer stays free of Firebase dependencies.
class UserModel extends User {
  const UserModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.dueDate,
    required super.currentWeek,
    required super.language,
    super.selectedClinicId,
    super.partnerUserId,
    super.profilePhotoUrl,
    required super.createdAt,
    required super.lastActiveAt,
  });

  /// Build a UserModel from a Firestore document snapshot.
  ///
  /// Handles all the type conversions Firestore needs:
  /// - Timestamps to DateTime
  /// - Missing optional fields to null
  /// - Missing required fields fall back to sensible defaults
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      userId: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phoneNumber: data['phone_number'] as String? ?? '',
      dueDate: _timestampToDateTime(data['due_date']) ?? DateTime.now(),
      currentWeek: (data['current_week'] as num?)?.toInt() ?? 1,
      language: data['language'] as String? ?? 'en',
      selectedClinicId: data['selected_clinic_id'] as String?,
      partnerUserId: data['partner_user_id'] as String?,
      profilePhotoUrl: data['profile_photo_url'] as String?,
      createdAt: _timestampToDateTime(data['created_at']) ?? DateTime.now(),
      lastActiveAt:
      _timestampToDateTime(data['last_active_at']) ?? DateTime.now(),
    );
  }

  /// Build a UserModel from a plain map (used in tests and cache reads).
  factory UserModel.fromMap(Map<String, dynamic> data, String userId) {
    return UserModel(
      userId: userId,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phoneNumber: data['phone_number'] as String? ?? '',
      dueDate: _timestampToDateTime(data['due_date']) ?? DateTime.now(),
      currentWeek: (data['current_week'] as num?)?.toInt() ?? 1,
      language: data['language'] as String? ?? 'en',
      selectedClinicId: data['selected_clinic_id'] as String?,
      partnerUserId: data['partner_user_id'] as String?,
      profilePhotoUrl: data['profile_photo_url'] as String?,
      createdAt: _timestampToDateTime(data['created_at']) ?? DateTime.now(),
      lastActiveAt:
      _timestampToDateTime(data['last_active_at']) ?? DateTime.now(),
    );
  }

  /// Convert this model to a Firestore-writable map.
  ///
  /// Field names match the ERD exactly (snake_case).
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'due_date': Timestamp.fromDate(dueDate),
      'current_week': currentWeek,
      'language': language,
      'selected_clinic_id': selectedClinicId,
      'partner_user_id': partnerUserId,
      'profile_photo_url': profilePhotoUrl,
      'created_at': Timestamp.fromDate(createdAt),
      'last_active_at': Timestamp.fromDate(lastActiveAt),
    };
  }

  /// Convert a pure User entity to a UserModel.
  ///
  /// Useful when the domain layer hands us a User and we need to persist it.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      userId: user.userId,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      dueDate: user.dueDate,
      currentWeek: user.currentWeek,
      language: user.language,
      selectedClinicId: user.selectedClinicId,
      partnerUserId: user.partnerUserId,
      profilePhotoUrl: user.profilePhotoUrl,
      createdAt: user.createdAt,
      lastActiveAt: user.lastActiveAt,
    );
  }

  /// Robust timestamp conversion.
  ///
  /// Firestore may return Timestamp, DateTime, int (ms since epoch),
  /// or String depending on the source. Handle all of them.
  static DateTime? _timestampToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}