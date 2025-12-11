import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  final TextEditingController _postcodeController = TextEditingController();

  void _searchByPostcode(String postcode) {
    if (postcode.isNotEmpty) {
      context.push('/property_floor_area?postcode=$postcode');
    }
  }

  @override
  void dispose() {
    _postcodeController.dispose();
    super.dispose();
  }

  Widget _buildGreyedOutField(String label) {
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
            Text('98375',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(width: 16),
            Text('British Land', style: TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage:
                  NetworkImage('https://picsum.photos/seed/picsum/200/300'),
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
                      const Text('Prev. Price', style: TextStyle(color: accentColor)),
                      const SizedBox(height: 8),
                      Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: trafficRed, width: 2))),
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
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: trafficGreen, width: 2))),
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
                    child: TextFormField(
                      controller: _postcodeController,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Address, Postcode, What2Words etc...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  _buildGreyedOutField('Type:'),
                  _buildGreyedOutField('Bedrooms:'),
                  _buildGreyedOutField('Size:'),
                  _buildGreyedOutField('Tenure:'),
                  _buildGreyedOutField('Parking Spaces:'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Text('£',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}
