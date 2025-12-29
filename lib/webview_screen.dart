
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/utils/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? postcode;

  const WebViewScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.address,
    this.postcode,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final Future<Uri> _streetViewUriFuture;

  @override
  void initState() {
    super.initState();
    _streetViewUriFuture = _getStreetViewUri();
  }

  Future<Uri> _getStreetViewUri() async {
    // Prioritize lat/lon if available and valid
    if (widget.latitude != null &&
        widget.longitude != null &&
        (widget.latitude != 0.0 || widget.longitude != 0.0)) {
      return _buildStreetViewUri(
          '${widget.latitude},${widget.longitude}');
    }

    // Otherwise, use the postcode to geocode the location
    if (widget.postcode != null && widget.postcode!.isNotEmpty) {
      try {
        final locationString = await _geocodePostcode(widget.postcode!);
        return _buildStreetViewUri(locationString);
      } catch (e) {
        // If geocoding fails, rethrow the error to be caught by the FutureBuilder
        rethrow;
      }
    }

    // If no valid location data is available, throw an error
    throw Exception('No valid location data provided.');
  }

  /// Converts a postcode into a "lat,lon" string using the Google Geocoding API.
  Future<String> _geocodePostcode(String postcode) async {
    final geocodeUri =
        Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'address': postcode,
      'key': googleMapsApiKey,
    });

    final response = await http.get(geocodeUri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        return '$lat,$lng';
      } else {
        throw Exception('Geocoding failed: ${data['status']}');
      }
    } else {
      throw Exception('Failed to connect to Geocoding API.');
    }
  }

  /// Constructs the final Google Street View Embed API Uri.
  Uri _buildStreetViewUri(String location) {
    return Uri.https('www.google.com', '/maps/embed/v1/streetview', {
      'key': googleMapsApiKey,
      'location': location,
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uri>(
      future: _streetViewUriFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error loading Street View: \n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (snapshot.hasData) {
          final controller = WebViewController()..loadRequest(snapshot.data!);
          return WebViewWidget(controller: controller);
        } else {
          return const Center(child: Text('Street View not available.'));
        }
      },
    );
  }
}
