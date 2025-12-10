import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/property.dart';
import 'dart:io';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _selectedScenarioIndex = 0;
  int _selectedIndex = 0;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  final List<XFile> _images = [];
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

  // Define costs for each scenario
  final Map<String, double> _developmentCosts = {
    'Full Refurbishment': 50000,
    'Extensions (Rear / Side / Front)': 100000,
    'Loft Conversion': 75000,
    'Garage Conversion': 25000,
  };

  @override
  void initState() {
    super.initState();
    _calculateFinancials();
  }

  void _calculateFinancials() {
    final selectedScenario = _houseScenarios[_selectedScenarioIndex];
    final developmentCost = _developmentCosts[selectedScenario] ?? 0;

    setState(() {
      _gdv = widget.property.gdvFinal ?? 0;
      _totalCost = widget.property.price + developmentCost;
      _uplift = _gdv - _totalCost;
      _roi = (_totalCost > 0) ? (_uplift / _totalCost) * 100 : 0;
    });
  }

  void _nextScenario() {
    setState(() {
      _selectedScenarioIndex = (_selectedScenarioIndex + 1) % _houseScenarios.length;
      _calculateFinancials(); // Recalculate on change
    });
  }

  void _previousScenario() {
    setState(() {
      _selectedScenarioIndex =
          (_selectedScenarioIndex - 1 + _houseScenarios.length) %
              _houseScenarios.length;
      _calculateFinancials(); // Recalculate on change
    });
  }

  Widget _buildScenarios(BuildContext context) {
    final bool isFlat = widget.property.type.toLowerCase() == 'flat';

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

    void _onItemTapped(int index) {
        setState(() {
        _selectedIndex = index;
        });

        switch (index) {
        case 0:
            // Stay on this screen
            break;
        case 1:
            _pickImages();
            break;
        case 2:
            context.push('/create_report', extra: widget.property);
            break;
        case 3:
            context.push('/share', extra: widget.property);
            break;
        case 4:
            // ignore for now
            break;
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
            child: const Icon(Icons.business), // Placeholder for company logo
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text('98375', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            const Text('British Land', style: TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings tap
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://picsum.photos/seed/picsum/200/300'), // Placeholder for user avatar
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
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
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
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final image = _images[index];
                                  return kIsWeb
                                      ? Image.network(
                                          image.path,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(image.path),
                                          fit: BoxFit.cover,
                                        );
                                },
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.white),
                                  onPressed: () => _removeImage(_currentImageIndex),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    '${_currentImageIndex + 1}/${_images.length}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                                      onPressed: () {
                                        _pageController.previousPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                                      onPressed: () {
                                        _pageController.nextPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : const Center(child: Text('Photos')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Price: ${currencyFormat.format(widget.property.price)}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Type: ${widget.property.type}'),
            Text('Bedrooms: ${widget.property.bedrooms}'),
            Text('Distance: ${widget.property.distance} miles'),
            Text('Location: (${widget.property.lat}, ${widget.property.lng})'),
            Text('Portal: ${widget.property.portal}'),
            Text('SSTC: ${widget.property.sstc == 1 ? 'Yes' : 'No'}'),
            if (widget.property.gdvSold != null)
              Text('GDV Sold: ${currencyFormat.format(widget.property.gdvSold)}'),
            if (widget.property.gdvOnmarket != null)
              Text(
                  'GDV On Market: ${currencyFormat.format(widget.property.gdvOnmarket)}'),
            if (widget.property.gdvArea != null)
              Text('GDV Area: ${currencyFormat.format(widget.property.gdvArea)}'),
            if (widget.property.gdvFinal != null)
              Text('GDV Final: ${currencyFormat.format(widget.property.gdvFinal)}'),
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
          BottomNavigationBarItem(
            icon: Text('£', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
