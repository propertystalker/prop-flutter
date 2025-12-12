import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/property.dart';
import '../models/property_floor_area.dart';
import '../utils/constants.dart';
import 'property_floor_area_screen.dart';
import 'report_sent_screen.dart';
import 'share_screen.dart';

class PropertyFloorAreaFilterScreen extends StatefulWidget {
  final KnownFloorArea area;
  final String postcode;

  const PropertyFloorAreaFilterScreen(
      {super.key, required this.area, required this.postcode});

  @override
  PropertyFloorAreaFilterScreenState createState() =>
      PropertyFloorAreaFilterScreenState();
}

class PropertyFloorAreaFilterScreenState
    extends State<PropertyFloorAreaFilterScreen> {
  final PageController _pageController = PageController();
  final List<XFile> _images = [];
  int _currentImageIndex = 0;
  int? _historicalPrice;
  bool _isLoadingHistoricalPrice = false;
  String? _historicalPriceError;
  bool _isLoadingPrice = true;
  String? _currentPriceError;

  // --- Replicated from PropertyDetailScreen ---
  int _selectedScenarioIndex = 0;
  final List<String> _houseScenarios = [
    'Full Refurbishment',
    'Extensions (Rear / Side / Front)',
    'Loft Conversion',
    'Garage Conversion',
  ];

  // Financial variables
  double _gdv = 0;
  double _totalCost = 0;
  double _uplift = 0;
  double _roi = 0;
  double _currentPrice = 0;

  // --- Editing State ---
  bool _isEditingPrice = false;
  late TextEditingController _priceController;
  final FocusNode _priceFocusNode = FocusNode();
  late TextEditingController _addressController;

  final Map<String, double> _developmentCosts = {
    'Full Refurbishment': 50000,
    'Extensions (Rear / Side / Front)': 100000,
    'Loft Conversion': 75000,
    'Garage Conversion': 25000,
    'Flat Refurbishment Only (1–3 bed)': 40000, // Added for flats
  };

  bool _isFinancePanelVisible = false;
  bool _sendReportToLender = false;

  bool _isReportPanelVisible = false;
  bool _inviteToSetupAccount = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _addressController = TextEditingController(text: widget.area.address);
    _fetchCurrentPrice();
    _fetchHistoricalPrice();
  }

  void _searchByPostcode(String postcode) {
    if (postcode.isNotEmpty) {
      // Pop the filter screen
      Navigator.of(context).pop();
      // Pop the previous screen
      Navigator.of(context).pop();
      // Push a new property floor area screen with the new postcode
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PropertyFloorAreaScreen(
            postcode: postcode,
            apiKey: apiKey, // Assuming apiKey is accessible here
          ),
        ),
      );
    }
  }

  Future<void> _fetchCurrentPrice() async {
    setState(() {
      _isLoadingPrice = true;
      _currentPriceError = null;
    });

    final bedrooms = widget.area.habitableRooms;
    final url = Uri.parse(
        'https://api.propertydata.co.uk/prices?key=$apiKey&postcode=${widget.postcode}&bedrooms=$bedrooms');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _currentPrice = (data['data']['average'] as int).toDouble();
            _priceController.text = _currentPrice.toStringAsFixed(0);
            _calculateFinancials();
          });
        } else {
          throw Exception('Failed to load price data: ${data['error']}');
        }
      } else {
        throw Exception('Failed to load price data');
      }
    } catch (e) {
      setState(() {
        _currentPriceError = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingPrice = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchHistoricalPrice() async {
    setState(() {
      _isLoadingHistoricalPrice = true;
      _historicalPriceError = null;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoadingHistoricalPrice = false;
      _historicalPrice = 153000;
    });
  }

  void _calculateFinancials() {
    final isFlat = widget.area.address.toLowerCase().contains('flat');
    final selectedScenario = isFlat
        ? 'Flat Refurbishment Only (1–3 bed)'
        : _houseScenarios[_selectedScenarioIndex];
    final developmentCost = _developmentCosts[selectedScenario] ?? 0;

    setState(() {
      _totalCost = _currentPrice + developmentCost;
      // Estimated GDV: for demo purposes, let's assume GDV is total cost + 25% uplift
      _gdv = _totalCost * 1.25;
      _uplift = _gdv - _totalCost;
      _roi = (_totalCost > 0) ? (_uplift / _totalCost) * 100 : 0;
    });
  }

  void _updatePrice(String value) {
    final newPrice = double.tryParse(value);
    if (newPrice != null && newPrice != _currentPrice) {
      setState(() {
        _currentPrice = newPrice;
        _calculateFinancials();
      });
    }
    setState(() {
      _isEditingPrice = false;
    });
  }

  void _nextScenario() {
    setState(() {
      _selectedScenarioIndex = (_selectedScenarioIndex + 1) % _houseScenarios.length;
      _calculateFinancials();
    });
  }

  void _previousScenario() {
    setState(() {
      _selectedScenarioIndex =
          (_selectedScenarioIndex - 1 + _houseScenarios.length) %
              _houseScenarios.length;
      _calculateFinancials();
    });
  }

  Widget _buildScenarios(BuildContext context) {
    final bool isFlat = widget.area.address.toLowerCase().contains('flat');

    if (isFlat) {
      return const ListTile(
        leading: Icon(Icons.apartment),
        title: Text('Flat Refurbishment Only (1–3 bed)'),
        subtitle: Text('Scenario'),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Development Scenarios',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: _previousScenario,
              ),
              Expanded(
                child: Text(
                  _houseScenarios[_selectedScenarioIndex],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: _nextScenario,
              ),
            ],
          ),
        ],
      );
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      if (_currentImageIndex >= _images.length && _images.isNotEmpty) {
        _currentImageIndex = _images.length - 1;
      }
    });
  }

  Widget _buildFinancePanel() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: trafficGreen, width: 2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request Finance Proposal',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            initialValue: 'Golden Trust Capital',
            decoration: const InputDecoration(
              labelText: 'Company Name',
              icon: Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            initialValue: 'chris@goldentrustcapital.co.uk',
            decoration: const InputDecoration(
              labelText: 'Company email address',
              icon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            initialValue: 'devfinance@bigbanklender.com',
            decoration: const InputDecoration(
              labelText: 'Bank lender email address',
              icon: Icon(Icons.account_balance),
            ),
          ),
          CheckboxListTile(
            title: const Text('Also send report to lender'),
            value: _sendReportToLender,
            onChanged: (bool? value) {
              setState(() {
                _sendReportToLender = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16.0),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send'),
              onPressed: () {
                // Implement send logic
                setState(() {
                  _isFinancePanelVisible = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportPanel() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: trafficYellow, width: 2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create & Send Report',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'From',
              icon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'To',
              icon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'CC',
              icon: Icon(Icons.people_outline),
            ),
          ),
          CheckboxListTile(
            title: const Text('Also invite to setup account'),
            value: _inviteToSetupAccount,
            onChanged: (bool? value) {
              setState(() {
                _inviteToSetupAccount = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16.0),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send'),
              onPressed: () {
                // Implement send logic
                setState(() {
                  _isReportPanelVisible = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditablePrice() {
    final currencyFormat = NumberFormat.compactSimpleCurrency(locale: 'en_GB');

    if (_isLoadingPrice) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    if (_currentPriceError != null) {
      return Text(
        'Error: Please try again',
        style: const TextStyle(color: Colors.white, fontSize: 18),
      );
    }

    if (_isEditingPrice) {
      return Container(
        color: editablePriceColor,
        width: 200, // Give it a specific width
        child: TextField(
          controller: _priceController,
          focusNode: _priceFocusNode,
          keyboardType: TextInputType.number,
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(8.0),
          ),
          onSubmitted: _updatePrice,
          onTapOutside: (_) => _updatePrice(_priceController.text),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            _isEditingPrice = true;
            _priceController.text = _currentPrice.toStringAsFixed(0);
          });
          // Request focus after the widget is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _priceFocusNode.requestFocus();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: editablePriceColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            currencyFormat.format(_currentPrice),
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.compactSimpleCurrency(locale: 'en_GB');

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Icon(Icons.business),
          ),
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('98375', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(width: 16),
            Text('British Land', style: TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://picsum.photos/seed/picsum/200/300'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                              border: Border.all(color: Colors.purple, width: 2),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Image.asset('assets/images/gemini.png'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            if (_isLoadingHistoricalPrice)
                              const CircularProgressIndicator()
                            else if (_historicalPrice != null)
                              Text(currencyFormat.format(_historicalPrice),
                                  style: const TextStyle(color: accentColor))
                            else if (_historicalPriceError != null)
                              Text(_historicalPriceError!,
                                  style: const TextStyle(color: accentColor))
                            else
                              const Text('Prev. Price',
                                  style: TextStyle(color: accentColor)),
                            const SizedBox(height: 8),
                            Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                    color: trafficRed, shape: BoxShape.circle)),
                            const SizedBox(height: 8),
                            Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                    color: trafficYellow, shape: BoxShape.circle)),
                            const SizedBox(height: 8),
                            Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                    color: trafficGreen, shape: BoxShape.circle)),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue, width: 2),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: _images.isNotEmpty
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        PageView.builder(
                                          controller: _pageController,
                                          itemCount: _images.length,
                                          onPageChanged: (index) =>
                                              setState(() => _currentImageIndex = index),
                                          itemBuilder: (context, index) {
                                            final image = _images[index];
                                            return ClipRRect(
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: kIsWeb
                                                  ? Image.network(image.path,
                                                      fit: BoxFit.cover)
                                                  : Image.file(File(image.path),
                                                      fit: BoxFit.cover),
                                            );
                                          },
                                        ),
                                        Positioned(
                                            top: 8,
                                            left: 8,
                                            child: IconButton(
                                                icon: const Icon(Icons.remove_circle,
                                                    color: Colors.white),
                                                onPressed: () =>
                                                    _removeImage(_currentImageIndex))),
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 4.0),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                            child: Text(
                                              '${_currentImageIndex + 1} / ${_images.length}',
                                              style: const TextStyle(
                                                  color: Colors.white, fontSize: 14),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.arrow_back_ios,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  if (_currentImageIndex > 0) {
                                                    _pageController.previousPage(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.easeInOut,
                                                    );
                                                  }
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  if (_currentImageIndex <
                                                      _images.length - 1) {
                                                    _pageController.nextPage(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.easeInOut,
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Center(
                                      child: Text('Your photos will appear here')),
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
                          child: TextFormField(
                            controller: _addressController,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search, color: Colors.white),
                                onPressed: () =>
                                    _searchByPostcode(_addressController.text),
                              ),
                            ),
                            onFieldSubmitted: _searchByPostcode,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildEditablePrice(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Text('Size: ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      Text(widget.area.squareFeet.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Text('Bedroom: ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      Text(widget.area.habitableRooms.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 32),
                        _buildScenarios(context),
                        const Divider(height: 32),
                        Text('GDV: ${currencyFormat.format(_gdv)}',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Total Cost: ${currencyFormat.format(_totalCost)}',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Uplift: ${currencyFormat.format(_uplift)}',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('ROI: ${_roi.toStringAsFixed(2)}%',
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isFinancePanelVisible) _buildFinancePanel(),
          if (_isReportPanelVisible) _buildReportPanel(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Text('£', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.share), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: ''),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            setState(() {
              _isFinancePanelVisible = !_isFinancePanelVisible;
              _isReportPanelVisible = false;
            });
          }
          if (index == 1) _pickImages();
          if (index == 2) {
            setState(() {
              _isReportPanelVisible = !_isReportPanelVisible;
              _isFinancePanelVisible = false;
            });
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportSentScreen()),
            );
          }
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShareScreen(
                  property: Property(
                    price: _currentPrice.toInt(),
                    bedrooms: widget.area.habitableRooms,
                    lat: '51.5074',
                    lng: '0.1278',
                    type: widget.area.address.toLowerCase().contains('flat')
                        ? 'flat'
                        : 'house',
                    distance: '0.1',
                    sstc: 0,
                    portal: 'OnTheMarket',
                    postcode: widget.postcode,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
