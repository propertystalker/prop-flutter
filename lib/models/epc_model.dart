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
  });

  factory EpcModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely cast values to String
    String _asString(dynamic value) {
      if (value == null) return 'N/A';
      return value.toString();
    }

    return EpcModel(
      address: _asString(json['address']),
      postcode: _asString(json['postcode']),
      currentEnergyRating: _asString(json['current-energy-rating']),
      potentialEnergyRating: _asString(json['potential-energy-rating']),
      propertyType: _asString(json['property-type']),
      builtForm: _asString(json['built-form']),
      mainFuel: _asString(json['main-fuel']),
      totalFloorArea: _asString(json['total-floor-area']),
      lodgementDate: _asString(json['lodgement-date']),
    );
  }
}
