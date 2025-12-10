
import 'package:flutter/material.dart';
import '../models/property_floor_area.dart';
import '../services/api_service.dart';

class PropertyFloorAreaScreen extends StatefulWidget {
  final String postcode;
  final String apiKey;

  const PropertyFloorAreaScreen(
      {Key? key, required this.postcode, required this.apiKey})
      : super(key: key);

  @override
  _PropertyFloorAreaScreenState createState() =>
      _PropertyFloorAreaScreenState();
}

class _PropertyFloorAreaScreenState extends State<PropertyFloorAreaScreen> {
  late Future<PropertyFloorAreaResponse> _floorAreasFuture;

  @override
  void initState() {
    super.initState();
    _floorAreasFuture = ApiService().getPropertyFloorAreas(
      apiKey: widget.apiKey,
      postcode: widget.postcode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Floor Areas for ${widget.postcode}'),
      ),
      body: FutureBuilder<PropertyFloorAreaResponse>(
        future: _floorAreasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              snapshot.data!.knownFloorAreas.isEmpty) {
            return const Center(child: Text('No floor area data found.'));
          } else {
            final floorAreas = snapshot.data!.knownFloorAreas;
            return ListView.builder(
              itemCount: floorAreas.length,
              itemBuilder: (context, index) {
                final area = floorAreas[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(area.address),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Square Feet: ${area.squareFeet}'),
                        Text('Habitable Rooms: ${area.habitableRooms}'),
                        Text('Inspection Date: ${area.inspectionDate}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
