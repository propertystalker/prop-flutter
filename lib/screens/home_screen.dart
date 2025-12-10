
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/property.dart';
import '../services/api_service.dart';
import 'property_floor_area_screen.dart'; // Import the new screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController(text: 'ZVUJN5EMPV');
  final _postcodeController = TextEditingController(text: 'W149JH');
  final _bedroomsController = TextEditingController(text: '2');

  final ApiService _apiService = ApiService();
  List<Property> _properties = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // You might want to trigger an initial search or load cached data here
  }

  void _fetchProperties() async {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      try {
        final properties = await _apiService.getProperties(
          apiKey: _apiKeyController.text,
          postcode: _postcodeController.text.toUpperCase(),
          bedrooms: int.parse(_bedroomsController.text),
        );
        if (mounted) {
          setState(() {
            _properties = properties;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _navigateToFloorAreaScreen() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PropertyFloorAreaScreen(
            apiKey: _apiKeyController.text,
            postcode: _postcodeController.text.toUpperCase(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an API key and postcode.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.compactSimpleCurrency(locale: 'en_GB');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(labelText: 'API Key'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an API key';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _postcodeController,
                    decoration: const InputDecoration(labelText: 'Postcode'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a postcode';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _bedroomsController,
                    decoration: const InputDecoration(labelText: 'Bedrooms'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of bedrooms';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _fetchProperties,
                        child: const Text('Search Prices'),
                      ),
                      ElevatedButton(
                        onPressed: _navigateToFloorAreaScreen,
                        child: const Text('Floor Areas'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: _properties.length,
                      itemBuilder: (context, index) {
                        final property = _properties[index];
                        return ListTile(
                          title: Text(currencyFormat.format(property.price)),
                          subtitle: Text(property.type),
                          onTap: () {
                            context.go('/property', extra: property);
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
