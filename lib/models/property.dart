
class Property {
  final int price;
  final String lat;
  final String lng;
  final int bedrooms;
  final String type;
  final String distance;
  final int sstc;
  final String portal;

  Property({
    required this.price,
    required this.lat,
    required this.lng,
    required this.bedrooms,
    required this.type,
    required this.distance,
    required this.sstc,
    required this.portal,
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
    );
  }
}
