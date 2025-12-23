class EpcModel {
  final String address;
  final String postcode;
  final String currentEnergyRating;
  final String potentialEnergyRating;
  final String propertyType;
  final String builtForm;
  final String? mainFuel;
  final String totalFloorArea;
  final String lodgementDate;
  final String numberHabitableRooms;
  final double latitude;
  final double longitude;

  EpcModel({
    required this.address,
    required this.postcode,
    required this.currentEnergyRating,
    required this.potentialEnergyRating,
    required this.propertyType,
    required this.builtForm,
    required this.mainFuel,
    required this.totalFloorArea,
    required this.lodgementDate,
    required this.numberHabitableRooms,
    required this.latitude,
    required this.longitude,
  });

  factory EpcModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely cast values
    String asString(dynamic value) {
      if (value == null) return 'N/A';
      return value.toString();
    }

    double asDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return EpcModel(
      address: asString(json['address']),
      postcode: asString(json['postcode']),
      currentEnergyRating: asString(json['current-energy-rating']),
      potentialEnergyRating: asString(json['potential-energy-rating']),
      propertyType: asString(json['property-type']),
      builtForm: asString(json['built-form']),
      mainFuel: asString(json['main-fuel']),
      totalFloorArea: asString(json['total-floor-area']),
      lodgementDate: asString(json['lodgement-date']),
      numberHabitableRooms: asString(json['number-habitable-rooms']),
      latitude: asDouble(json['latitude']),
      longitude: asDouble(json['longitude']),
    );
  }
}
