/// Represents a health facility that integrates with SafeMom.
///
/// Clinics are curated data — users select one during onboarding
/// as their preferred facility for emergency dispatch and appointments.
///
/// Pure Dart entity — no Firebase, no Flutter dependencies.
/// Fields match the `clinics` collection in the ERD.
class Clinic {
  final String clinicId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String contactPhone;
  final List<ClinicService> servicesOffered;
  final bool is24Hours;

  const Clinic({
    required this.clinicId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.contactPhone,
    required this.servicesOffered,
    this.is24Hours = false,
  });

  /// True if this clinic offers emergency maternity services.
  bool get supportsEmergency => servicesOffered.contains(ClinicService.emergency);

  /// True if this clinic offers routine antenatal care.
  bool get supportsAntenatal => servicesOffered.contains(ClinicService.antenatal);

  Clinic copyWith({
    String? clinicId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? contactPhone,
    List<ClinicService>? servicesOffered,
    bool? is24Hours,
  }) {
    return Clinic(
      clinicId: clinicId ?? this.clinicId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactPhone: contactPhone ?? this.contactPhone,
      servicesOffered: servicesOffered ?? this.servicesOffered,
      is24Hours: is24Hours ?? this.is24Hours,
    );
  }
}

/// Services a clinic may offer.
enum ClinicService {
  antenatal,
  emergency,
  maternity,
  nicu,
  ultrasound,
  labTests,
  vaccinations,
  postnatal,
}