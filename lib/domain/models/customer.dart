enum CustomerTier { regular, vip }

class Customer {
  const Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.tier = CustomerTier.regular,
    this.notes,
    this.totalOrders = 0,
    this.totalSpent = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? country;
  final CustomerTier tier;
  final String? notes;
  final int totalOrders;
  final double totalSpent;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    CustomerTier? tier,
    String? notes,
    int? totalOrders,
    double? totalSpent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Customer(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        city: city ?? this.city,
        country: country ?? this.country,
        tier: tier ?? this.tier,
        notes: notes ?? this.notes,
        totalOrders: totalOrders ?? this.totalOrders,
        totalSpent: totalSpent ?? this.totalSpent,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
