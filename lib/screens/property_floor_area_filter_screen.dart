import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controllers/company_controller.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/widgets/company_account.dart';
import 'package:provider/provider.dart';
import '../widgets/development_scenarios.dart';
import '../widgets/financial_summary.dart';
import '../widgets/filter_screen_bottom_nav.dart';
import '../widgets/finance_panel.dart';
import '../widgets/property_filter_app_bar.dart';
import '../widgets/report_panel.dart';
import '../widgets/traffic_light_indicator.dart';
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

  // --- Editing State ---
  bool _isEditingPrice = false;
  late TextEditingController _priceController;
  final FocusNode _priceFocusNode = FocusNode();
  late TextEditingController _addressController;

  bool _isFinancePanelVisible = false;
  bool _sendReportToLender = false;

  bool _isReportPanelVisible = false;
  bool _inviteToSetupAccount = false;
  bool _isCompanyAccountVisible = false;

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
          final currentPrice = (data['data']['average'] as int).toDouble();
          Provider.of<FinancialController>(context, listen: false).setCurrentPrice(currentPrice);
          _priceController.text = currentPrice.toStringAsFixed(0);
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

  void _updatePrice(String value) {
    final newPrice = double.tryParse(value);
    if (newPrice != null) {
       Provider.of<FinancialController>(context, listen: false).setCurrentPrice(newPrice);
    }
    setState(() {
      _isEditingPrice = false;
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

  Widget _buildEditablePrice(FinancialController controller) {
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
            _priceController.text = controller.currentPrice.toStringAsFixed(0);
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
            currencyFormat.format(controller.currentPrice),
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FinancialController, CompanyController>(
      builder: (context, financialController, companyController, child) {
        return Scaffold(
          appBar: PropertyFilterAppBar(
            onLogoTap: () {
              setState(() {
                _isCompanyAccountVisible = !_isCompanyAccountVisible;
              });
            },
          ),
          body: Column(
            children: [
              if (_isCompanyAccountVisible)
                CompanyAccount(
                  onCompanyChanged: (name) {
                    companyController.setCompanyName(name);
                  },
                  onSave: () {
                    setState(() {
                      _isCompanyAccountVisible = false;
                    });
                  },
                ),
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
                            TrafficLightIndicator(
                              isLoading: _isLoadingHistoricalPrice,
                              price: _historicalPrice,
                              error: _historicalPriceError,
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
                            _buildEditablePrice(financialController),
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
                            DevelopmentScenarios(
                              isFlat: widget.area.address.toLowerCase().contains('flat'),
                              selectedScenario: financialController.houseScenarios[financialController.selectedScenarioIndex],
                              onPrevious: () => financialController.previousScenario(widget.area.address.toLowerCase().contains('flat')),
                              onNext: () => financialController.nextScenario(widget.area.address.toLowerCase().contains('flat')),
                            ),
                            const Divider(height: 32),
                            FinancialSummary(
                              gdv: financialController.gdv,
                              totalCost: financialController.totalCost,
                              uplift: financialController.uplift,
                              roi: financialController.roi,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isFinancePanelVisible)
                FinancePanel(
                  sendReportToLender: _sendReportToLender,
                  onSendReportToLenderChanged: (bool? value) {
                    setState(() {
                      _sendReportToLender = value ?? false;
                    });
                  },
                  onSend: () {
                    setState(() {
                      _isFinancePanelVisible = false;
                    });
                  },
                ),
              if (_isReportPanelVisible)
                ReportPanel(
                  inviteToSetupAccount: _inviteToSetupAccount,
                  onInviteToSetupAccountChanged: (bool? value) {
                    setState(() {
                      _inviteToSetupAccount = value ?? false;
                    });
                  },
                  onSend: () {
                    setState(() {
                      _isReportPanelVisible = false;
                    });
                  },
                ),
            ],
          ),
          bottomNavigationBar: FilterScreenBottomNav(
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
                        price: financialController.currentPrice.toInt(),
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
      },
    );
  }
}
