import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/property.dart';
import '../services/api_service.dart';

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

  final Map<String, List<Property>> _cache = {};

  @override
  void initState() {
    super.initState();
    _precacheW149JHData();
  }

  void _precacheW149JHData() {
    const cachedJson = '''
    {
      "status": "success",
      "postcode": "W14 9JH",
      "postcode_type": "full",
      "url": "https://propertydata.co.uk/draw?input=W14+9JH",
      "bedrooms": 2,
      "data": {
        "points_analysed": 20,
        "radius": "0.09",
        "average": 664500,
        "70pc_range": [
          499000,
          865000
        ],
        "80pc_range": [
          495000,
          1075000
        ],
        "90pc_range": [
          485000,
          2450000
        ],
        "100pc_range": [
          475000,
          2900000
        ],
        "raw_data": [
          {
            "price": 575000,
            "lat": "51.48886900",
            "lng": "-0.20776300",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.00",
            "sstc": 0,
            "portal": "onthemarket.com"
          },
          {
            "price": 550000,
            "lat": "51.48897100",
            "lng": "-0.20744900",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.01",
            "sstc": 0,
            "portal": "onthemarket.com"
          },
          {
            "price": 650000,
            "lat": "51.48897000",
            "lng": "-0.20744820",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.01",
            "sstc": 0,
            "portal": "onthemarket.com"
          },
          {
            "price": 625000,
            "lat": "51.48864800",
            "lng": "-0.20783300",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.02",
            "sstc": 1,
            "portal": "rightmove.co.uk"
          },
          {
            "price": 2450000,
            "lat": "51.48846000",
            "lng": "-0.20738750",
            "bedrooms": 2,
            "type": "detached_house",
            "distance": "0.03",
            "sstc": 0,
            "portal": "onthemarket.com"
          },
          {
            "price": 2900000,
            "lat": "51.48850900",
            "lng": "-0.20741900",
            "bedrooms": 2,
            "type": "detached_house",
            "distance": "0.03",
            "sstc": 0,
            "portal": "onthemarket.com"
          },
          {
            "price": 600000,
            "lat": "51.48818500",
            "lng": "-0.20771700",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.05",
            "sstc": 1,
            "portal": "zoopla.co.uk"
          },
          {
            "price": 475000,
            "lat": "51.48822500",
            "lng": "-0.20872100",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.06",
            "sstc": 0,
            "portal": "zoopla.co.uk"
          },
          {
            "price": 485000,
            "lat": "51.48870900",
            "lng": "-0.20901500",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.06",
            "sstc": 1,
            "portal": "rightmove.co.uk"
          },
          {
            "price": 495000,
            "lat": "51.48969000",
            "lng": "-0.20737900",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.06",
            "sstc": 0,
            "portal": "rightmove.co.uk"
          },
          {
            "price": 625000,
            "lat": "51.48806800",
            "lng": "-0.20739300",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.06",
            "sstc": 0,
            "portal": "zoopla.co.uk"
          },
          {
            "price": 725000,
            "lat": "51.48873200",
            "lng": "-0.20911800",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.06",
            "sstc": 1,
            "portal": "rightmove.co.uk"
          },
          {
            "price": 675000,
            "lat": "51.48796000",
            "lng": "-0.20729700",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.07",
            "sstc": 0,
            "portal": "rightmove.co.uk"
          },
          {
            "price": 750000,
            "lat": "51.48861400",
            "lng": "-0.20629300",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.07",
            "sstc": 0,
            "portal": "rightmove.co.uk"
          },
          {
            "price": 825000,
            "lat": "51.48778000",
            "lng": "-0.20738000",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.08",
            "sstc": 0,
            "portal": "rightmove.co.uk"
          },
          {
            "price": 1075000,
            "lat": "51.48997000",
            "lng": "-0.20860000",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.08",
            "sstc": 0,
            "portal": "zoopla.co.uk"
          },
          {
            "price": 499000,
            "lat": "51.48983900",
            "lng": "-0.20916000",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.09",
            "sstc": 0,
            "portal": "zoopla.co.uk"
          },
          {
            "price": 595000,
            "lat": "51.48926800",
            "lng": "-0.20569200",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.09",
            "sstc": 0,
            "portal": "rightmove.co.uk"
          },
          {
            "price": 825000,
            "lat": "51.48808300",
            "lng": "-0.20628500",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.09",
            "sstc": 0,
            "portal": "rightmove.co.uk"
          },
          {
            "price": 865000,
            "lat": "51.48946700",
            "lng": "-0.20585000",
            "bedrooms": 2,
            "type": "flat",
            "distance": "0.09",
            "sstc": 0,
            "portal": "rightmove.co.uk"
          }
        ]
      },
      "process_time": "2.32"
    }
    ''';

    final decodedData = json.decode(cachedJson);
    final properties = (decodedData['data']['raw_data'] as List)
        .map((data) => Property.fromJson(data))
        .toList();
    _cache['W149JH'] = properties;
  }

  void _fetchProperties() async {
    if (_formKey.currentState!.validate()) {
      final postcode = _postcodeController.text.toUpperCase();
      if (_cache.containsKey(postcode)) {
        setState(() {
          _properties = _cache[postcode]!;
        });
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      try {
        final properties = await _apiService.getProperties(
          apiKey: _apiKeyController.text,
          postcode: postcode,
          bedrooms: int.parse(_bedroomsController.text),
        );
        if (mounted) {
          setState(() {
            _properties = properties;
            _cache[postcode] = properties;
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
                  ElevatedButton(
                    onPressed: _fetchProperties,
                    child: const Text('Search'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
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
