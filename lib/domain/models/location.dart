enum LocationType { warehouse, store, office, customer, shipping, other }

class Location {
  const Location({
    required this.id,
    required this.name,
    this.type = LocationType.warehouse,
    this.address,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.contactPerson,
    this.contactPhone,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final LocationType type;
  final String? address;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? contactPerson;
  final String? contactPhone;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get fullAddress {
    final parts = [address, city, country].where((s) => s != null && s.isNotEmpty);
    return parts.isNotEmpty ? parts.join(', ') : 'No address specified';
  }

  bool get hasCoordinates => latitude != null && longitude != null;

  Location copyWith({
    String? id,
    String? name,
    LocationType? type,
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? contactPerson,
    String? contactPhone,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Location(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        address: address ?? this.address,
        city: city ?? this.city,
        country: country ?? this.country,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        contactPerson: contactPerson ?? this.contactPerson,
        contactPhone: contactPhone ?? this.contactPhone,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
