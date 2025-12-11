import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/property_floor_area.dart';
import '../services/api_service.dart';
import 'property_floor_area_filter_screen.dart';

class PropertyFloorAreaScreen extends StatefulWidget {
  final String postcode;
  final String apiKey;

  const PropertyFloorAreaScreen(
      {super.key, required this.postcode, required this.apiKey});

  @override
  _PropertyFloorAreaScreenState createState() =>
      _PropertyFloorAreaScreenState();
}

class _PropertyFloorAreaScreenState extends State<PropertyFloorAreaScreen> {
  late Future<PropertyFloorAreaResponse> _floorAreasFuture;

  // Hardcoded JSON data for the specific postcode
  final String _cachedPostcode = 'W149JH';
  final String _cachedJsonResponse = '''
  {
    "status": "success",
    "postcode": "W14 9JH",
    "postcode_type": "full",
    "known_floor_areas": [
      {
        "inspection_date": "2016-08-31",
        "address": "Third Floor Flat, 32 Charleville Road",
        "square_feet": 603,
        "habitable_rooms": 3
      },
      {
        "inspection_date": "2016-04-13",
        "address": "Flat B8, 32 Charleville Road",
        "square_feet": 258,
        "habitable_rooms": 1
      },
      {
        "inspection_date": "2016-03-22",
        "address": "First Floor Flat, 46 Charleville Road",
        "square_feet": 603,
        "habitable_rooms": 2
      },
      {
        "inspection_date": "2016-02-02",
        "address": "18b Charleville Road",
        "square_feet": 258,
        "habitable_rooms": 1
      },
      {
        "inspection_date": "2015-12-15",
        "address": "Flat 1, 48 Charleville Road",
        "square_feet": 215,
        "habitable_rooms": 1
      }
    ],
    "process_time": "0.03"
  }
  ''';

  @override
  void initState() {
    super.initState();
    // Normalize the input postcode for a reliable comparison
    final normalizedPostcode = widget.postcode.replaceAll(' ', '').toUpperCase();

    if (normalizedPostcode == _cachedPostcode) {
      // If it's the cached postcode, use the hardcoded JSON
      _floorAreasFuture = Future.value(
        PropertyFloorAreaResponse.fromJson(
          json.decode(_cachedJsonResponse),
        ),
      );
    } else {
      // Otherwise, fetch from the API as usual
      _floorAreasFuture = ApiService().getPropertyFloorAreas(
        apiKey: widget.apiKey,
        postcode: widget.postcode,
      );
    }
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
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyFloorAreaFilterScreen(
                            area: area,
                          ),
                        ),
                      );
                    },
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
