
class PropertyFloorAreaResponse {
  final String status;
  final String postcode;
  final String postcodeType;
  final List<KnownFloorArea> knownFloorAreas;

  PropertyFloorAreaResponse({
    required this.status,
    required this.postcode,
    required this.postcodeType,
    required this.knownFloorAreas,
  });

  factory PropertyFloorAreaResponse.fromJson(Map<String, dynamic> json) {
    var list = json['known_floor_areas'] as List;
    List<KnownFloorArea> areasList =
        list.map((i) => KnownFloorArea.fromJson(i)).toList();

    return PropertyFloorAreaResponse(
      status: json['status'],
      postcode: json['postcode'],
      postcodeType: json['postcode_type'],
      knownFloorAreas: areasList,
    );
  }
}

class KnownFloorArea {
  final String inspectionDate;
  final String address;
  final int squareFeet;
  final int habitableRooms;

  KnownFloorArea({
    required this.inspectionDate,
    required this.address,
    required this.squareFeet,
    required this.habitableRooms,
  });

  factory KnownFloorArea.fromJson(Map<String, dynamic> json) {
    return KnownFloorArea(
      inspectionDate: json['inspection_date'],
      address: json['address'],
      squareFeet: json['square_feet'],
      habitableRooms: json['habitable_rooms'],
    );
  }
}
