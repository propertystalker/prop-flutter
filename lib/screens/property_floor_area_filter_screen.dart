
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/property_floor_area.dart';
import 'package:intl/intl.dart';

class PropertyFloorAreaFilterScreen extends StatefulWidget {
  final KnownFloorArea area;

  const PropertyFloorAreaFilterScreen({Key? key, required this.area}) : super(key: key);

  @override
  _PropertyFloorAreaFilterScreenState createState() => _PropertyFloorAreaFilterScreenState();
}

class _PropertyFloorAreaFilterScreenState extends State<PropertyFloorAreaFilterScreen> {
  final PageController _pageController = PageController();
  final List<XFile> _images = [];
  int _currentImageIndex = 0;
  int? _historicalPrice;
  bool _isLoadingHistoricalPrice = false;
  String? _historicalPriceError;

  @override
  void initState() {
    super.initState();
    _fetchHistoricalPrice();
  }

  Future<void> _fetchHistoricalPrice() async {
    setState(() {
      _isLoadingHistoricalPrice = true;
      _historicalPriceError = null;
    });
    // Fake network delay to show loading indicator
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoadingHistoricalPrice = false;
      _historicalPrice = 153000; // Simulate a successful fetch
    });
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
            onPressed: () {},
          ),
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
                      Text(
                        currencyFormat.format(_historicalPrice),
                        style: const TextStyle(color: Color(0xFF94529C)),
                      )
                    else if (_historicalPriceError != null)
                      Text(
                        _historicalPriceError!,
                        style: const TextStyle(color: Color(0xFF94529C)),
                      )
                    else
                      const Text(
                        'Prev. Price',
                        style: TextStyle(color: Color(0xFF94529C)),
                      ),
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
                                Positioned(top: 8, left: 8, child: IconButton(icon: const Icon(Icons.remove_circle, color: Colors.white), onPressed: () => _removeImage(_currentImageIndex))),
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
              child: Text(currencyFormat.format(575000), // Placeholder value
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF317CD3))),
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
