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
import 'package:myapp/models/planning_application.dart';
import 'package:myapp/models/scenario_model.dart';
import 'package:myapp/screens/property/widgets/growth_per_square_foot_widget.dart';
import 'package:myapp/screens/property/widgets/price_per_square_foot.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/services/planning_service.dart';
import 'package:myapp/services/property_data_service.dart';
import 'package:myapp/utils/constants.dart';
import 'package:myapp/widgets/build_cost_details.dart';
import 'package:myapp/widgets/company_account.dart';
import 'package:myapp/widgets/debug_widget.dart';
import 'package:myapp/widgets/gdv_calculation_widget.dart';
import 'package:myapp/widgets/gdv_range_widget.dart';
import 'package:myapp/widgets/person_account.dart';
import 'package:myapp/screens/property/widgets/image_gallery.dart';
import 'package:myapp/screens/property/widgets/price_history.dart';
import 'package:myapp/screens/property/widgets/property_header.dart';
import 'package:myapp/screens/property/widgets/property_stats.dart';
import 'package:myapp/widgets/planning_applications_widget.dart';
import 'package:myapp/widgets/scenario_selection_panel.dart';
import 'package:myapp/widgets/uplift_analysis_widget.dart';
import 'package:myapp/widgets/uplift_risk_overview_widget.dart';
import 'package:provider/provider.dart';
import 'package:myapp/widgets/development_scenarios.dart';
import 'package:myapp/widgets/financial_summary.dart';
import 'package:myapp/widgets/filter_screen_bottom_nav.dart';
import 'package:myapp/widgets/finance_panel.dart';
import 'package:myapp/widgets/property_filter_app_bar.dart';
import 'package:myapp/widgets/report_panel.dart';
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
  bool _isScenarioSelectionVisible = false;
  bool _isGeneratingReport = false;
  double? _lastGdv;
  String? _streetViewUrl;
  List<PlanningApplication> _planningApplications = [];
  List<PlanningApplication> _propertyDataPlanningApplications = [];
  bool _isLoadingPlanningApps = true;

  final List<Scenario> _scenarios = [
    Scenario(id: 'REFURB_FULL', name: 'Full refurbishment'),
    Scenario(id: 'FRONT_SINGLE', name: 'Full-width front single-storey'),
    Scenario(id: 'REAR_SINGLE', name: 'Rear single-storey'),
    Scenario(id: 'FRONT_DOUBLE', name: 'Full-width front two-storey'),
    Scenario(id: 'REAR_DOUBLE', name: 'Rear two-storey'),
    Scenario(id: 'GARAGE_SINGLE', name: 'Standard single garage'),
    Scenario(id: 'SIDE_SINGLE', name: 'Side single-storey'),
    Scenario(id: 'LOFT_BASIC', name: 'Basic loft conversion'),
    Scenario(id: 'SIDE_DOUBLE', name: 'Side two-storey'),
    Scenario(id: 'LOFT_DORMER', name: 'Dormer loft conversion'),
    Scenario(id: 'LOFT_DORMER_ENSUITE', name: 'Dormer loft with ensuite'),
  ];

  @override
  void initState() {
    super.initState();
    _pricePaidController = Provider.of<PricePaidController>(context, listen: false);
    _financialController = Provider.of<FinancialController>(context, listen: false);
    _gdvController = Provider.of<GdvController>(context, listen: false);
    _imageGalleryController = ImageGalleryController();

    _financialController.updatePropertyData(
      totalFloorArea: double.tryParse(widget.epc.totalFloorArea) ?? 0.0,
      propertyType: widget.epc.propertyType,
      builtForm: widget.epc.builtForm, // Correctly pass the builtForm
      epcRating: widget.epc.currentEnergyRating,
    );

    _lastGdv = _gdvController.finalGdv;

    _pricePaidController.addListener(_onPriceHistoryChanged);
    _gdvController.addListener(_onGdvChanged);
    _financialController.addListener(_onCurrentPriceChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
      _fetchPlanningApplications();
      _fetchPropertyDataPlanningApplications();
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

  Future<void> _fetchData() async {
    await _fetchPriceHistory();
    await _fetchGrowthPerSquareFoot();

    final currentPrice = _financialController.currentPrice ?? 0.0;
    
    await _gdvController.calculateGdv(
      habitableRooms: int.tryParse(widget.epc.numberHabitableRooms) ?? 0,
      totalFloorArea: double.tryParse(widget.epc.totalFloorArea) ?? 0.0,
      currentPrice: currentPrice,
    );
  }

  Future<void> _fetchGrowthPerSquareFoot() async {
    try {
      final growthData = await ApiService().getGrowthPerSquareFoot(
        apiKey: apiKey,
        postcode: widget.epc.postcode,
      );
      if (mounted && growthData.isNotEmpty) {
        final latestGrowth = growthData.last.growth;
        _financialController.setMarketGrowth(latestGrowth);
      }
    } catch (e) {
      debugPrint("Error fetching growth per square foot data: $e");
    }
  }

  Future<void> _fetchPlanningApplications() async {
    try {
      final apps = await PlanningService().getPlanningApplications(widget.epc.postcode);
      if (mounted) {
        setState(() {
          _planningApplications = apps;
          _isLoadingPlanningApps = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching planning applications: $e");
      if (mounted) {
        setState(() {
          _isLoadingPlanningApps = false;
        });
      }
    }
  }

  Future<void> _fetchPropertyDataPlanningApplications() async {
    try {
      final apps = await PropertyDataService().getPlanningApplications(widget.epc.postcode);
      if (mounted) {
        setState(() {
          _propertyDataPlanningApplications = apps;
        });
      }
    } catch (e) {
      debugPrint("Error fetching property data planning applications: $e");
    }
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
      final scenarioUplift = _gdvController.scenarioUplifts[_financialController.selectedScenario]?.uplift ?? 0.0;
      _financialController.calculateFinancials(
        _financialController.selectedScenario,
        _gdvController.finalGdv,
        scenarioUplift,
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

  Future<void> _fetchPriceHistory() async {
    final addressParts = widget.epc.address.split(',');
    final houseNumber = addressParts.isNotEmpty ? addressParts.first.trim() : '';

    if (houseNumber.isNotEmpty) {
      await _pricePaidController.fetchPricePaidHistoryForProperty(
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

  Future<void> _toggleScenarioSelectionVisibility() async {
    if (_isScenarioSelectionVisible || _isGeneratingReport) {
      setState(() {
        _isScenarioSelectionVisible = false;
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
        _isScenarioSelectionVisible = true;
      });
    } catch (e) {
      debugPrint("Error generating street view URL: $e");
    } finally {
      setState(() {
        _isGeneratingReport = false;
      });
    }
  }

  Future<String> _getBestLocationString() async {
    if (widget.epc.latitude != 0.0 || widget.epc.longitude != 0.0) {
      return '${widget.epc.latitude},${widget.epc.longitude}';
    }

    final fullAddress = widget.epc.address;
    final postcode = widget.epc.postcode;

    if (fullAddress.isNotEmpty && postcode.isNotEmpty) {
      try {
        final addressToGeocode = '$fullAddress, $postcode';
        return await _geocodeAddress(addressToGeocode);
      } catch (e) {
        debugPrint('Failed to geocode full address, falling back to postcode: $e');
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
              child: Stack(
                children: [
                  SingleChildScrollView(
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
                                propertyType: widget.epc.propertyType,
                              ),
                              const Divider(height: 32),
                              Consumer2<FinancialController, GdvController>(
                                builder: (context, financialController, gdvController, child) {
                                  return DevelopmentScenarios(
                                    onScenarioChanged: (scenario) {
                                      final scenarioUplift = gdvController.scenarioUplifts[scenario]?.uplift ?? 0.0;
                                      financialController.calculateFinancials(
                                          scenario, gdvController.finalGdv, scenarioUplift);
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
                              const BuildCostDetails(),
                              const Divider(height: 32),
                              const UpliftRiskOverviewWidget(),
                              const Divider(height: 32),
                              const UpliftAnalysisWidget(),
                              const Divider(height: 32),
                               PlanningApplicationsWidget(
                                planningApplications: _planningApplications,
                                isLoading: _isLoadingPlanningApps,
                              ),
                              const Divider(height: 32),
                              const PriceHistory(),
                              const Divider(height: 32),
                              PricePerSquareFootWidget(postcode: widget.epc.postcode),
                              const Divider(height: 32),
                              GrowthPerSquareFootWidget(postcode: widget.epc.postcode),
                              const SizedBox(height: 16),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Home'),
                                ),
                              ),
                              const SizedBox(height: 100),
                              const DebugWidget(),
                            ],
                          ),
                        ),
                        SizedBox(height: _isScenarioSelectionVisible ? 400 : 0),
                      ],
                    ),
                  ),
                  if (_isGeneratingReport)
                    const Center(child: CircularProgressIndicator()),
                  if (_isScenarioSelectionVisible)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: const Color.fromRGBO(0, 0, 0, 0.7),
                        child: Column(
                          children: [
                            ScenarioSelectionPanel(
                              scenarios: _scenarios,
                              onScenarioSelected: (id, isSelected) {
                                setState(() {
                                  final scenario = _scenarios.firstWhere((s) => s.id == id);
                                  scenario.isSelected = isSelected;
                                });
                              },
                            ),
                            Consumer2<FinancialController, ImageGalleryController>(
                              builder: (context, financialController, imageGalleryController, child) {
                                final selectedScenarioNames = _scenarios
                                    .where((s) => s.isSelected)
                                    .map((s) => s.name)
                                    .toList();

                                final propertyId = "${widget.epc.address}, ${widget.epc.postcode}";

                                return ReportPanel(
                                  propertyId: propertyId,
                                  address: widget.epc.address,
                                  price: NumberFormat.compactSimpleCurrency(locale: 'en_GB').format(financialController.currentPrice ?? 0),
                                  images: imageGalleryController.images,
                                  streetViewUrl: _streetViewUrl,
                                  propertyDataApplications: _propertyDataPlanningApplications,
                                  planitApplications: _planningApplications,
                                  selectedScenarios: selectedScenarioNames,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_isFinancePanelVisible)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: FinancePanel(onSend: () => setState(() => _isFinancePanelVisible = false)),
                    ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: FilterScreenBottomNav(onTap: (index) {
          if (index == 0) _toggleFinancePanelVisibility();
          if (index == 2) _toggleScenarioSelectionVisibility();
        }),
      ),
    );
  }
}
