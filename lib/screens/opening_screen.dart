import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/email_login_screen.dart';
import 'package:myapp/services/mapbox_service.dart';
import 'package:myapp/widgets/filter_screen_bottom_nav.dart';
import 'package:myapp/widgets/property_filter_app_bar.dart';
import 'package:searchfield/searchfield.dart';
import '../utils/constants.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  final TextEditingController _addressController = TextEditingController();
  final MapboxService _mapboxService = MapboxService(mapboxAccessToken);
  String _selectedPostcode = '';

  bool _isGettingLocation = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _searchByPostcode() async {
    if (_addressController.text.isEmpty) {
      await _getCurrentLocation(searchAfter: true);
    } else {
      if (_selectedPostcode.isNotEmpty) {
        context.push('/epc?postcode=$_selectedPostcode');
      } else {
        _showErrorSnackBar('Please select an address from the suggestions.');
      }
    }
  }

  Future<void> _getCurrentLocation({bool searchAfter = false}) async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          _showErrorSnackBar('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        _showPermissionDeniedSnackBar();
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      
      if (searchAfter) {
        final reverseGeocodeResult = await _mapboxService.reverseGeocode(position.latitude, position.longitude);

        if (!mounted) return;
        
        if (reverseGeocodeResult != null) {
          final postcodeContext = reverseGeocodeResult['context'].firstWhere(
              (c) => c['id'].toString().startsWith('postcode'),
              orElse: () => null);
          if (postcodeContext != null) {
            final postcode = postcodeContext['text'] ?? '';
            setState(() {
              _selectedPostcode = postcode;
              _addressController.text = reverseGeocodeResult['place_name'] ?? '';
            });
            context.push('/epc?postcode=$postcode');
          }
        }
      }
      if (!mounted) return;
      _showSuccessSnackBar('Location acquired successfully!');
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error getting location: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
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
                          flex: 5,
                          child: SearchField<Map<String, dynamic>>(
                            controller: _addressController,
                            suggestions: const [],
                            searchInputDecoration: SearchInputDecoration(
                              hintText: 'Address, Postcode, etc...',
                              hintStyle:
                                  TextStyle(color: Colors.white.withAlpha(179)),
                              border: InputBorder.none,
                              suffixIcon: _isGettingLocation
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : IconButton(
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
                                  _selectedPostcode = postcode;
                                });

                                if (postcode.isNotEmpty) {
                                  context.push(
                                      '/epc?postcode=$postcode&houseNumber=$houseNumber');
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
                  const SizedBox(height: 16),
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