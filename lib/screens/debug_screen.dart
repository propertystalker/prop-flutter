import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/email_login_screen.dart';
import 'package:myapp/services/mapbox_service.dart';
import 'package:myapp/widgets/filter_screen_bottom_nav.dart';
import 'package:myapp/widgets/property_filter_app_bar.dart';
import 'package:searchfield/searchfield.dart';
import '../utils/constants.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _flatNumberController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  final MapboxService _mapboxService = MapboxService(mapboxAccessToken);
  String _selectedPostcode = '';

  bool _isGettingLocation = false;

  @override
  void dispose() {
    _addressController.dispose();
    _houseNumberController.dispose();
    _flatNumberController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _limitController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  void _searchByPostcode() {
    if (_selectedPostcode.isNotEmpty) {
      final houseNumber = _houseNumberController.text;
      final flatNumber = _flatNumberController.text;
      context.push(
          '/epc?postcode=$_selectedPostcode&houseNumber=$houseNumber&flatNumber=$flatNumber');
    } else {
      _showErrorSnackBar('Please select an address from the suggestions.');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedSnackBar();
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
      });
      _showSuccessSnackBar('Location acquired successfully!');
    } catch (e) {
      _showErrorSnackBar('Error getting location: $e');
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPermissionDeniedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Location permissions are permanently denied.'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OPEN SETTINGS',
          textColor: Colors.white,
          onPressed: () {
            Geolocator.openAppSettings();
          },
        ),
      ),
    );
  }

  Widget buildGreyedOutField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PropertyFilterAppBar(
        onLogoTap: () {},
        onAvatarTap: () {},
        onSettingsTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EmailLoginScreen()),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/gemini.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    children: [
                      Text('Prev. Price', style: TextStyle(color: accentColor)),
                      SizedBox(height: 8),
                      SizedBox(
                          width: 24,
                          height: 24,
                          child: DecoratedBox(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.fromBorderSide(BorderSide(
                                      color: trafficRed, width: 2))))),
                      SizedBox(height: 8),
                      SizedBox(
                          width: 24,
                          height: 24,
                          child: DecoratedBox(
                              decoration: BoxDecoration(
                                  color: trafficYellow,
                                  shape: BoxShape.circle))),
                      SizedBox(height: 8),
                      SizedBox(
                          width: 24,
                          height: 24,
                          child: DecoratedBox(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.fromBorderSide(BorderSide(
                                      color: trafficGreen, width: 2))))),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Spot Potential',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Discover opportunities available here & investment required to uplift the property including new value!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              color: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _houseNumberController,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'House No.',
                              hintStyle:
                                  TextStyle(color: Colors.white.withAlpha(179)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _flatNumberController,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Flat No.',
                              hintStyle:
                                  TextStyle(color: Colors.white.withAlpha(179)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 5,
                          child: SearchField<Map<String, dynamic>>(
                            controller: _addressController,
                            suggestions: const [],
                            searchInputDecoration: SearchInputDecoration(
                              hintText: 'Address, Postcode, etc...',
                              hintStyle:
                                  TextStyle(color: Colors.white.withAlpha(179)),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search, color: Colors.white),
                                onPressed: _searchByPostcode,
                              ),
                            ),
                            onSearchTextChanged: (query) async {
                              if (query.length >= 5) {
                                final suggestions = await _mapboxService
                                    .getAutocompleteSuggestions(query);
                                return suggestions
                                    .map((e) =>
                                        SearchFieldListItem<Map<String, dynamic>>(
                                            e['place_name'],
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(e['place_name']),
                                            ),
                                            item: e))
                                    .toList();
                              }
                              return [];
                            },
                            onSuggestionTap:
                                (SearchFieldListItem<Map<String, dynamic>>
                                    item) {
                              FocusScope.of(context).unfocus();
                              final feature = item.item;
                              if (feature != null) {
                                final String placeName = feature['place_name'] ?? '';
                                final String houseNumber = feature['address'] ?? '';
                                String postcode = '';

                                final postcodeContext = feature['context'].firstWhere(
                                    (c) => c['id'].toString().startsWith('postcode'),
                                    orElse: () => null);
                                if (postcodeContext != null) {
                                  postcode = postcodeContext['text'] ?? '';
                                }

                                setState(() {
                                  _addressController.text = placeName;
                                  _houseNumberController.text = houseNumber;
                                  _selectedPostcode = postcode;
                                });

                                if (postcode.isNotEmpty) {
                                  final flatNumber = _flatNumberController.text;
                                  context.push(
                                      '/epc?postcode=$postcode&houseNumber=$houseNumber&flatNumber=$flatNumber');
                                }
                              }
                            },
                            itemHeight: 50,
                            suggestionsDecoration: SuggestionDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('£266k',
                          style: TextStyle(color: accentColor, fontSize: 24)),
                      Text('£270k',
                          style: TextStyle(
                              color: accentColor,
                              fontSize: 36,
                              fontWeight: FontWeight.bold)),
                      Text('£307k',
                          style: TextStyle(color: accentColor, fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isGettingLocation ? null : _getCurrentLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isGettingLocation
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'GET LOCATION',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _latitudeController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _longitudeController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Limit',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _radiusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Radius',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedPostcode.isNotEmpty) {
                        final houseNumber = _houseNumberController.text;
                        final flatNumber = _flatNumberController.text;
                        context.push(
                            '/price_paid?postcode=$_selectedPostcode&houseNumber=$houseNumber&flatNumber=$flatNumber');
                      } else {
                        _showErrorSnackBar('Please enter a postcode');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'GET PRICE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedPostcode.isNotEmpty) {
                        final houseNumber = _houseNumberController.text;
                        final flatNumber = _flatNumberController.text;
                        context.push(
                            '/epc?postcode=$_selectedPostcode&houseNumber=$houseNumber&flatNumber=$flatNumber');
                      } else {
                        _showErrorSnackBar('Please enter a postcode');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'GET EPC',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Opening Screen'),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    color: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Center(
                      child: Text(
                        'AUTOMATED VALUATION',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildGreyedOutField('Type:'),
                  buildGreyedOutField('Bedrooms:'),
                  buildGreyedOutField('Size:'),
                  buildGreyedOutField('Tenure:'),
                  buildGreyedOutField('Parking Spaces:'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FilterScreenBottomNav(),
    );
  }
}
