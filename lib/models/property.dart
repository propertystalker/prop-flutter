
class Property {
  final int price;
  final String lat;
  final String lng;
  final int bedrooms;
  final String type;
  final String distance;
  final int sstc;
  final String portal;
  final double? gdv_sold;
  final double? gdv_onmarket;
  final double? gdv_area;
  final double? gdv_final;

  Property({
    required this.price,
    required this.lat,
    required this.lng,
    required this.bedrooms,
    required this.type,
    required this.distance,
    required this.sstc,
    required this.portal,
    this.gdv_sold,
    this.gdv_onmarket,
    this.gdv_area,
    this.gdv_final,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      price: json['price'],
      lat: json['lat'],
      lng: json['lng'],
      bedrooms: json['bedrooms'],
      type: json['type'],
      distance: json['distance'],
      sstc: json['sstc'],
      portal: json['portal'],
      gdv_sold: json['gdv_sold']?.toDouble(),
      gdv_onmarket: json['gdv_onmarket']?.toDouble(),
      gdv_area: json['gdv_area']?.toDouble(),
      gdv_final: json['gdv_final']?.toDouble(),
    );
  }
}
