
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
  _PropertyFloorAreaFilterScreenState createState() =>
      _PropertyFloorAreaFilterScreenState();
}

class _PropertyFloorAreaFilterScreenState
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

  // Financial variables
  double _gdv = 0;
  double _totalCost = 0;
  double _uplift = 0;
  double _roi = 0;
  final double _currentPrice = 575000; // Using the placeholder price from the UI

  final Map<String, double> _developmentCosts = {
    'Full Refurbishment': 50000,
    'Extensions (Rear / Side / Front)': 100000,
    'Loft Conversion': 75000,
    'Garage Conversion': 25000,
    'Flat Refurbishment Only (1–3 bed)': 40000, // Added for flats
  };
  // --- End of Replicated code ---

  @override
  void initState() {
    super.initState();
    _fetchHistoricalPrice();
    _calculateFinancials(); // Initial calculation
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

  // --- Replicated and adapted from PropertyDetailScreen ---
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
  // --- End of Replicated code ---

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating report...')),
    );
    await ReportGenerator.generateReport(
      area: widget.area,
      images: _images,
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      Text(currencyFormat.format(_historicalPrice), style: const TextStyle(color: Color(0xFF94529C)))
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
            const SizedBox(height: 16),
            Center(
              child: Text(currencyFormat.format(_currentPrice), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF317CD3))),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.area.address, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildDetailRow(context, label: 'Size', value: widget.area.squareFeet.toString()),
                    const SizedBox(height: 12),
                    _buildDetailRow(context, label: 'Bedroom', value: widget.area.habitableRooms.toString()),
                  ],
                ),
              ),
            ),
            const Divider(height: 32),
            _buildScenarios(context),
            const Divider(height: 32),
            Text('GDV: ${currencyFormat.format(_gdv)}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Total Cost: ${currencyFormat.format(_totalCost)}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Uplift: ${currencyFormat.format(_uplift)}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('ROI: ${_roi.toStringAsFixed(2)}%', style: Theme.of(context).textTheme.titleMedium),
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

  Widget _buildDetailRow(BuildContext context, {required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
