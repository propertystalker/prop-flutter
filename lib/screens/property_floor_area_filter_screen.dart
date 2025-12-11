import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/property_floor_area.dart';
import '../services/report_generator.dart';

class PropertyFloorAreaFilterScreen extends StatefulWidget {
  final KnownFloorArea area;

  const PropertyFloorAreaFilterScreen({super.key, required this.area});

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

  // --- Replicated from PropertyDetailScreen ---
  int _selectedScenarioIndex = 0;
  final List<String> _houseScenarios = [
    'Full Refurbishment',
    'Extensions (Rear / Side / Front)',
    'Loft Conversion',
    'Garage Conversion',
  ];

  // --- Financial variables ---
  double _gdv = 0;
  double _totalCost = 0;
  double _uplift = 0;
  double _roi = 0;
  double _currentPrice = 575000;

  // --- Editing State ---
  bool _isEditingPrice = false;
  late TextEditingController _priceController;
  final FocusNode _priceFocusNode = FocusNode();

  final Map<String, double> _developmentCosts = {
    'Full Refurbishment': 50000,
    'Extensions (Rear / Side / Front)': 100000,
    'Loft Conversion': 75000,
    'Garage Conversion': 25000,
    'Flat Refurbishment Only (1–3 bed)': 40000,
  };

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: _currentPrice.toStringAsFixed(0));
    _fetchHistoricalPrice();
    _calculateFinancials();
  }

  @override
  void dispose() {
    _priceController.dispose();
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

  Future<void> _handleGenerateReport() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating report...')),
    );
    await ReportGenerator.generateReport(
      area: widget.area,
      images: _images,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  Widget _buildEditablePrice() {
    final currencyFormat = NumberFormat.compactSimpleCurrency(locale: 'en_GB');

    if (_isEditingPrice) {
      return Container(
        color: const Color(0xFF94ABBE),
        width: 200, // Give it a specific width
        child: TextField(
          controller: _priceController,
          focusNode: _priceFocusNode,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
            color: const Color(0xFF94ABBE),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            currencyFormat.format(_currentPrice),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        border: Border.all(color: Colors.purple, width: 2),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Center(child: Text('Comparables')),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      if (_isLoadingHistoricalPrice)
                        const CircularProgressIndicator()
                      else if (_historicalPrice != null)
                        Text(NumberFormat.compactSimpleCurrency(locale: 'en_GB').format(_historicalPrice), style: const TextStyle(color: Color(0xFF94529C)))
                      else if (_historicalPriceError != null)
                        Text(_historicalPriceError!, style: const TextStyle(color: Color(0xFF94529C)))
                      else
                        const Text('Prev. Price', style: TextStyle(color: Color(0xFF94529C))),
                      const SizedBox(height: 8),
                      Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                      const SizedBox(height: 8),
                      Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                      const SizedBox(height: 8),
                      Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
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
                                children: [
                                  PageView.builder(
                                    controller: _pageController,
                                    itemCount: _images.length,
                                    onPageChanged: (index) => setState(() => _currentImageIndex = index),
                                    itemBuilder: (context, index) {
                                      final image = _images[index];
                                      return kIsWeb ? Image.network(image.path, fit: BoxFit.cover) : Image.file(File(image.path), fit: BoxFit.cover);
                                    },
                                  ),
                                  Positioned(
                                      top: 8,
                                      left: 8,
                                      child: IconButton(
                                          icon: const Icon(Icons.remove_circle, color: Colors.white),
                                          onPressed: () => _removeImage(_currentImageIndex))),
                                ],
                              )
                            : const Center(child: Text('Photos')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              color: const Color(0xFF317CD3),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    widget.area.address,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Size', style: Theme.of(context).textTheme.titleMedium),
                                Text(widget.area.squareFeet.toString(), style: Theme.of(context).textTheme.titleMedium),
                              ],
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Bedroom', style: Theme.of(context).textTheme.titleMedium),
                                Text(widget.area.habitableRooms.toString(), style: Theme.of(context).textTheme.titleMedium),
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
                  Text('GDV: ${NumberFormat.compactSimpleCurrency(locale: 'en_GB').format(_gdv)}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Total Cost: ${NumberFormat.compactSimpleCurrency(locale: 'en_GB').format(_totalCost)}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Uplift: ${NumberFormat.compactSimpleCurrency(locale: 'en_GB').format(_uplift)}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('ROI: ${_roi.toStringAsFixed(2)}%', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Text('£', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), label: ''),
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
          if (index == 0) _handleGenerateReport();
          if (index == 1) _pickImages();
        },
      ),
    );
  }
}
