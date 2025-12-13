class Property {
  final int price;
  final String lat;
  final String lng;
  final int bedrooms;
  final String type;
  final String distance;
  final int sstc;
  final String portal;
  final String postcode;
  final double? gdvSold;
  final double? gdvOnMarket;
  final double? gdvArea;
  final double? gdvFinal;

  Property({
    required this.price,
    required this.lat,
    required this.lng,
    required this.bedrooms,
    required this.type,
    required this.distance,
    required this.sstc,
    required this.portal,
    required this.postcode,
    this.gdvSold,
    this.gdvOnMarket,
    this.gdvArea,
    this.gdvFinal,
  });

  factory Property.fromJson(Map<String, dynamic> json, {String? postcode}) {
    return Property(
      price: json['price'],
      lat: json['lat'],
      lng: json['lng'],
      bedrooms: json['bedrooms'],
      type: json['type'],
      distance: json['distance'],
      sstc: json['sstc'],
      portal: json['portal'],
      postcode: postcode ?? '',
      gdvSold: json['gdv_sold']?.toDouble(),
      gdvOnMarket: json['gdv_onmarket']?.toDouble(),
      gdvArea: json['gdv_area']?.toDouble(),
      gdvFinal: json['gdv_final']?.toDouble(),
    );
  }
}
