import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/services/mapbox_service.dart';
import 'package:myapp/services/postcode_service.dart';
import 'package:myapp/widgets/filter_screen_bottom_nav.dart';
import 'package:myapp/widgets/property_filter_app_bar.dart';
import '../utils/constants.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  final TextEditingController _postcodeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  final PostcodeService _postcodeService = PostcodeService();
  final MapboxService _mapboxService =
      MapboxService('pk.eyJ1IjoibGliZXJ0eWFwcHMiLCJhIjoiY21qNWxmaWI2MGJweDNlcXl0YWVuZDNwOCJ9.IoDlZx2i4TkloNRt9P8Q-w');
  List<String> _suggestions = [];
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _searchFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  bool _isGettingLocation = false;
  bool _isGettingPostcode = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
    _postcodeController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _postcodeController.removeListener(_onSearchChanged);
    _postcodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _limitController.dispose();
    _radiusController.dispose();
    _focusNode.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onSearchChanged() async {
    // A small delay to prevent firing requests on every keystroke
    await Future.delayed(const Duration(milliseconds: 300));
    if (_postcodeController.text.isNotEmpty && _focusNode.hasFocus) {
      final suggestions = await _mapboxService.getAutocompleteSuggestions(_postcodeController.text);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
        });
        _overlayEntry?.markNeedsBuild();
      }
    } else {
      if (mounted) {
        setState(() {
          _suggestions = [];
        });
        _overlayEntry?.markNeedsBuild();
      }
    }
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = _searchFieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    // THE FIX:
                    // 1. Stop listening to prevent the race condition.
                    _postcodeController.removeListener(_onSearchChanged);

                    // 2. Update the controller's text.
                    _postcodeController.text = suggestion;

                    // 3. Unfocus the field, which will trigger the listener to hide the overlay.
                    _focusNode.unfocus();
                    
                    // 4. Re-add the listener for the next search.
                    _postcodeController.addListener(_onSearchChanged);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _searchByPostcode(String postcode) {
    if (postcode.isNotEmpty) {
      context.push('/property_floor_area?postcode=$postcode');
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

  Future<void> _getPostcode() async {
    final lat = double.tryParse(_latitudeController.text);
    final lon = double.tryParse(_longitudeController.text);

    if (lat == null || lon == null) {
      _showErrorSnackBar('Invalid latitude or longitude format.');
      return;
    }

    setState(() {
      _isGettingPostcode = true;
    });

    try {
      final postcodes = await _postcodeService.getPostcodeFromCoordinates(lat, lon);

      if (postcodes != null && postcodes.isNotEmpty) {
        _showPostcodeDialog(postcodes);
      } else {
        _showErrorSnackBar('Could not find any postcodes for the given coordinates.');
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching postcode: $e');
    } finally {
      setState(() {
        _isGettingPostcode = false;
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

  void _showPostcodeDialog(List<String> postcodes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Found Postcodes'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: postcodes.length,
            itemBuilder: (context, index) {
              final postcode = postcodes[index];
              return ListTile(
                title: Text(postcode),
                onTap: () {
                  _postcodeController.text = postcode;
                  Navigator.of(context).pop();
                  _showSuccessSnackBar('Postcode selected: $postcode');
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
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
            MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                    child: CompositedTransformTarget(
                      key: _searchFieldKey, // Assign the key here
                      link: _layerLink,
                      child: TextFormField(
                        focusNode: _focusNode,
                        controller: _postcodeController,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Address, Postcode, What2Words etc...',
                          hintStyle:
                              TextStyle(color: Colors.white.withAlpha(179)),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () =>
                                _searchByPostcode(_postcodeController.text),
                          ),
                        ),
                        onFieldSubmitted: _searchByPostcode,
                      ),
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
                    onPressed: _isGettingPostcode ? null : _getPostcode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isGettingPostcode
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
                            'GET POSTCODE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
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
