/// Waypoint between pickup and final destination (server contract S6-2a).
class BookingRouteStop {
  const BookingRouteStop({
    required this.lat,
    required this.lng,
    required this.address,
    this.placeId,
  });

  final double lat;
  final double lng;
  final String address;
  final String? placeId;

  Map<String, dynamic> toServerJson() => {
        'lat': lat,
        'lng': lng,
        'address': address,
        if (placeId != null && placeId!.trim().isNotEmpty)
          'placeId': placeId!.trim(),
      };

  factory BookingRouteStop.fromJson(Map<String, dynamic> json) {
    return BookingRouteStop(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: '${json['address'] ?? ''}'.trim(),
      placeId: json['placeId']?.toString(),
    );
  }
}
