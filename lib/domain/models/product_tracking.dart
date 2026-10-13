enum TrackingStatus {
  created,
  draft,
  active,
  inStock,
  reserved,
  processing,
  prepared,
  shipped,
  inTransit,
  arrivedAtHub,
  outForDelivery,
  delivered,
  returned,
  cancelled,
}

class TrackingEvent {
  const TrackingEvent({
    required this.id,
    required this.productId,
    required this.status,
    this.statusTitle,
    this.locationName,
    this.locationAddress,
    this.latitude,
    this.longitude,
    this.actorName,
    this.actorRole,
    this.description,
    this.referenceNumber,
    this.notes,
    required this.timestamp,
  });

  final String id;
  final String productId;
  final TrackingStatus status;
  final String? statusTitle;
  final String? locationName;
  final String? locationAddress;
  final double? latitude;
  final double? longitude;
  final String? actorName;
  final String? actorRole;
  final String? description;
  final String? referenceNumber;
  final String? notes;
  final DateTime timestamp;

  String get displayStatus => statusTitle ?? status.name;

  TrackingEvent copyWith({
    String? id,
    String? productId,
    TrackingStatus? status,
    String? statusTitle,
    String? locationName,
    String? locationAddress,
    double? latitude,
    double? longitude,
    String? actorName,
    String? actorRole,
    String? description,
    String? referenceNumber,
    String? notes,
    DateTime? timestamp,
  }) =>
      TrackingEvent(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        status: status ?? this.status,
        statusTitle: statusTitle ?? this.statusTitle,
        locationName: locationName ?? this.locationName,
        locationAddress: locationAddress ?? this.locationAddress,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        actorName: actorName ?? this.actorName,
        actorRole: actorRole ?? this.actorRole,
        description: description ?? this.description,
        referenceNumber: referenceNumber ?? this.referenceNumber,
        notes: notes ?? this.notes,
        timestamp: timestamp ?? this.timestamp,
      );
}

class ProductTrackingSummary {
  const ProductTrackingSummary({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.currentStatus,
    this.currentLocationName,
    this.currentLocationAddress,
    required this.events,
    required this.lastUpdated,
  });

  final String productId;
  final String productName;
  final String sku;
  final TrackingStatus currentStatus;
  final String? currentLocationName;
  final String? currentLocationAddress;
  final List<TrackingEvent> events;
  final DateTime lastUpdated;

  TrackingEvent? get latestEvent => events.isNotEmpty ? events.first : null;
}
