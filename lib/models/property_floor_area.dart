class PropertyFloorAreaResponse {
  final String status;
  final List<KnownFloorArea> knownFloorArea;
  final String processTime;

  PropertyFloorAreaResponse({
    required this.status,
    required this.knownFloorArea,
    required this.processTime,
  });

  factory PropertyFloorAreaResponse.fromJson(Map<String, dynamic> json) {
    var list = json['known_floor_area'] as List;
    List<KnownFloorArea> knownFloorAreaList =
        list.map((i) => KnownFloorArea.fromJson(i)).toList();

    return PropertyFloorAreaResponse(
      status: json['status'],
      knownFloorArea: knownFloorAreaList,
      processTime: json['process_time'],
    );
  }
}

class KnownFloorArea {
  final String? inspectionDate;
  final String address;
  final int squareMeters;
  final int habitableRooms;
  final String postcode;

  KnownFloorArea({
    this.inspectionDate,
    required this.address,
    required this.squareMeters,
    required this.habitableRooms,
    required this.postcode,
  });

  factory KnownFloorArea.fromJson(Map<String, dynamic> json) {
    return KnownFloorArea(
      inspectionDate: json['inspection_date'],
      address: json['address'],
      squareMeters: json['square_feet'], // The API uses 'square_feet', so we'll keep this mapping for now
      habitableRooms: json['habitable_rooms'],
      postcode: json['postcode'],
    );
  }
}
