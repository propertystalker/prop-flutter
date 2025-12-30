import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myapp/controllers/finance_proposal_request_controller.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/controllers/gdv_controller.dart';
import 'package:myapp/controllers/image_gallery_controller.dart';
import 'package:myapp/controllers/price_paid_controller.dart';
import 'package:myapp/controllers/send_report_request_controller.dart';
import 'package:myapp/models/epc_model.dart';
import 'package:myapp/utils/constants.dart';
import 'package:myapp/widgets/company_account.dart';
import 'package:myapp/widgets/gdv_calculation_widget.dart';
import 'package:myapp/widgets/gdv_range_widget.dart';
import 'package:myapp/widgets/person_account.dart';
import 'package:myapp/screens/property/widgets/image_gallery.dart';
import 'package:myapp/screens/property/widgets/price_history.dart';
import 'package:myapp/screens/property/widgets/property_header.dart';
import 'package:myapp/screens/property/widgets/property_stats.dart';
import 'package:myapp/widgets/uplift_analysis_widget.dart';
import 'package:myapp/widgets/uplift_risk_overview_widget.dart';
import 'package:provider/provider.dart';
import 'package:myapp/widgets/development_scenarios.dart';
import 'package:myapp/widgets/financial_summary.dart';
import 'package:myapp/widgets/filter_screen_bottom_nav.dart';
import 'package:myapp/widgets/finance_panel.dart';
import 'package:myapp/widgets/property_filter_app_bar.dart';
import 'package:myapp/widgets/report_panel.dart';
import 'package:myapp/screens/report_sent_screen.dart';
import 'package:myapp/webview_screen.dart';

class PropertyScreen extends StatefulWidget {
  final EpcModel epc;

  const PropertyScreen({super.key, required this.epc});

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  late PricePaidController _pricePaidController;
  late GdvController _gdvController;
  late FinancialController _financialController;
  late ImageGalleryController _imageGalleryController;
  bool _isCompanyAccountVisible = false;
  bool _isPersonAccountVisible = false;
  bool _isFinancePanelVisible = false;
  bool _isReportPanelVisible = false;
  bool _isGeneratingReport = false;
  double? _lastGdv;
  String? _streetViewUrl;

  @override
  void initState() {
    super.initState();
    _pricePaidController = Provider.of<PricePaidController>(context, listen: false);
    _financialController = Provider.of<FinancialController>(context, listen: false);
    _gdvController = Provider.of<GdvController>(context, listen: false);
    _imageGalleryController = ImageGalleryController();

    _lastGdv = _gdvController.finalGdv;

    _pricePaidController.addListener(_onPriceHistoryChanged);
    _gdvController.addListener(_onGdvChanged);
    _financialController.addListener(_onCurrentPriceChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _pricePaidController.removeListener(_onPriceHistoryChanged);
    _gdvController.removeListener(_onGdvChanged);
    _financialController.removeListener(_onCurrentPriceChanged);
    _imageGalleryController.dispose();
    super.dispose();
  }

  void _fetchData() {
    _fetchPriceHistory();
    _gdvController.calculateGdv(
      postcode: widget.epc.postcode,
      habitableRooms: int.tryParse(widget.epc.numberHabitableRooms) ?? 0,
      totalFloorArea: double.tryParse(widget.epc.totalFloorArea) ?? 0.0,
    );
  }

  void _onPriceHistoryChanged() {
    if (mounted && !_pricePaidController.isLoading) {
      if (_pricePaidController.priceHistory.isNotEmpty) {
        final latestPrice =
            _pricePaidController.priceHistory.first.amount.toDouble();
        _financialController.setCurrentPrice(latestPrice, _gdvController.finalGdv);
      } else {
        _financialController.setCurrentPrice(_gdvController.finalGdv, _gdvController.finalGdv);
      }
    }
  }

  void _onGdvChanged() {
    if (mounted && _gdvController.finalGdv != _lastGdv) {
      _lastGdv = _gdvController.finalGdv;
      _financialController.calculateFinancials(
        _financialController.selectedScenario,
        _gdvController.finalGdv,
      );
    }
  }

  void _onCurrentPriceChanged() {
    if (mounted) {
      final currentPrice = _financialController.currentPrice;
      final totalFloorArea = double.tryParse(widget.epc.totalFloorArea) ?? 0.0;
      if (currentPrice != null) {
        _gdvController.updateUpliftRates(
          currentPrice: currentPrice,
          totalFloorArea: totalFloorArea,
        );
      }
    }
  }

  void _fetchPriceHistory() {
    final addressParts = widget.epc.address.split(',');
    final houseNumber = addressParts.isNotEmpty ? addressParts.first.trim() : '';

    if (houseNumber.isNotEmpty) {
      _pricePaidController.fetchPricePaidHistoryForProperty(
          widget.epc.postcode, houseNumber);
    }
  }

  void _toggleCompanyAccountVisibility() {
    setState(() {
      _isCompanyAccountVisible = !_isCompanyAccountVisible;
    });
  }

  void _togglePersonAccountVisibility() {
    setState(() {
      _isPersonAccountVisible = !_isPersonAccountVisible;
    });
  }

  void _toggleFinancePanelVisibility() {
    setState(() {
      _isFinancePanelVisible = !_isFinancePanelVisible;
    });
  }

  Future<void> _toggleReportPanelVisibility() async {
    if (_isReportPanelVisible || _isGeneratingReport) {
      setState(() {
        _isReportPanelVisible = false;
      });
      return;
    }

    setState(() {
      _isGeneratingReport = true;
    });

    try {
      final locationString = await _getBestLocationString();
      final streetViewUrl =
        'https://maps.googleapis.com/maps/api/streetview?size=600x400&location=$locationString&key=$googleMapsApiKey';
      
      setState(() {
        _streetViewUrl = streetViewUrl;
        _isReportPanelVisible = true;
      });
    } catch (e) {
      print("Error generating street view URL: $e");
      // Optionally, show an error message to the user
    } finally {
      setState(() {
        _isGeneratingReport = false;
      });
    }
  }

  Future<String> _getBestLocationString() async {
    if (widget.epc.latitude != null &&
        widget.epc.longitude != null &&
        (widget.epc.latitude != 0.0 || widget.epc.longitude != 0.0)) {
      return '${widget.epc.latitude},${widget.epc.longitude}';
    }

    final fullAddress = widget.epc.address;
    final postcode = widget.epc.postcode;

    if (fullAddress.isNotEmpty && postcode.isNotEmpty) {
      try {
        final addressToGeocode = '$fullAddress, $postcode';
        return await _geocodeAddress(addressToGeocode);
      } catch (e) {
        // Fallback to postcode if full address fails
        print('Failed to geocode full address, falling back to postcode: $e');
      }
    }

    if (postcode.isNotEmpty) {
      return await _geocodeAddress(postcode);
    }

    throw Exception('No valid location data provided for Street View.');
  }

  Future<String> _geocodeAddress(String address) async {
    final geocodeUri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'address': address,
      'key': googleMapsApiKey,
    });

    final response = await http.get(geocodeUri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return '${location['lat']},${location['lng']}';
      } else {
        throw Exception('Geocoding failed: ${data['status']} - ${data['error_message']}');
      }
    } else {
      throw Exception('Failed to connect to Geocoding API.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceProposalRequestController()),
        ChangeNotifierProvider(create: (_) => SendReportRequestController()),
        ChangeNotifierProvider.value(value: _gdvController),
        ChangeNotifierProvider.value(value: _financialController),
        ChangeNotifierProvider.value(value: _imageGalleryController),
      ],
      child: Scaffold(
        appBar: PropertyFilterAppBar(
          onLogoTap: _toggleCompanyAccountVisibility,
          onAvatarTap: _togglePersonAccountVisibility,
        ),
        body: Column(
          children: [
            if (_isCompanyAccountVisible) const CompanyAccount(),
            if (_isPersonAccountVisible) const PersonAccount(),
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
                              child: WebViewScreen(
                                latitude: widget.epc.latitude,
                                longitude: widget.epc.longitude,
                                address: widget.epc.address,
                                postcode: widget.epc.postcode,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: ImageGallery(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<FinancialController>(
                      builder: (context, financialController, child) {
                        return PropertyHeader(
                          address: widget.epc.address,
                          postcode: widget.epc.postcode,
                          price: financialController.currentPrice,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          PropertyStats(
                            squareMeters: (double.tryParse(widget.epc.totalFloorArea) ?? 0.0).round(),
                            habitableRooms:
                                int.tryParse(widget.epc.numberHabitableRooms) ?? 0,
                            propertyType: widget.epc.propertyType,
                          ),
                          const Divider(height: 32),
                          Consumer2<FinancialController, GdvController>(
                            builder: (context, financialController, gdvController, child) {
                              return DevelopmentScenarios(
                                onScenarioChanged: (scenario) {
                                  financialController.calculateFinancials(
                                      scenario, gdvController.finalGdv);
                                },
                              );
                            },
                          ),
                          const Divider(height: 32),
                          const GdvCalculationWidget(),
                          const Divider(height: 32),
                          const GdvRangeWidget(),
                          const Divider(height: 32),
                          Consumer<FinancialController>(
                            builder: (context, financialController, child) =>
                                FinancialSummary(
                              gdv: financialController.gdv,
                              totalCost: financialController.totalCost,
                              uplift: financialController.uplift,
                              roi: financialController.roi,
                            ),
                          ),
                          const Divider(height: 32),
                          const UpliftRiskOverviewWidget(),
                          const Divider(height: 32),
                          const UpliftAnalysisWidget(),
                          const Divider(height: 32),
                          const PriceHistory(),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Home'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isGeneratingReport)
              const Center(child: CircularProgressIndicator()),
            if (_isFinancePanelVisible)
              FinancePanel(onSend: () => setState(() => _isFinancePanelVisible = false)),
            if (_isReportPanelVisible)
              Consumer2<FinancialController, ImageGalleryController>(
                builder: (context, financialController, imageGalleryController, child) => ReportPanel(
                  address: widget.epc.address,
                  price: NumberFormat.compactSimpleCurrency(locale: 'en_GB')
                      .format(financialController.currentPrice ?? 0),
                  images: imageGalleryController.images,
                  streetViewUrl: _streetViewUrl,
                  gdv: financialController.gdv,
                  totalCost: financialController.totalCost,
                  uplift: financialController.uplift,
                  onSend: () {
                    _toggleReportPanelVisibility();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReportSentScreen()),
                    );
                  },
                ),
              ),
          ],
        ),
        bottomNavigationBar: FilterScreenBottomNav(onTap: (index) {
          if (index == 0) _toggleFinancePanelVisibility();
          if (index == 2) _toggleReportPanelVisibility();
        }),
      ),
    );
  }
}
