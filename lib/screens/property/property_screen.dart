import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controllers/finance_proposal_request_controller.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/controllers/gdv_controller.dart';
import 'package:myapp/controllers/price_paid_controller.dart';
import 'package:myapp/controllers/send_report_request_controller.dart';
import 'package:myapp/models/epc_model.dart';
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
  bool _isCompanyAccountVisible = false;
  bool _isPersonAccountVisible = false;
  bool _isFinancePanelVisible = false;
  bool _isReportPanelVisible = false;

  @override
  void initState() {
    super.initState();
    _pricePaidController = Provider.of<PricePaidController>(context, listen: false);
    _financialController = Provider.of<FinancialController>(context, listen: false);
    _gdvController = Provider.of<GdvController>(context, listen: false);

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
    // When GDV changes, we need to recalculate the financials
    _financialController.calculateFinancials(
      _financialController.selectedScenario, 
      _gdvController.finalGdv
    );
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

  void _toggleReportPanelVisibility() {
    setState(() {
      _isReportPanelVisible = !_isReportPanelVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceProposalRequestController()),
        ChangeNotifierProvider(create: (_) => SendReportRequestController()),
        ChangeNotifierProvider.value(value: _gdvController),
        ChangeNotifierProvider.value(value: _financialController),
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
                              child: Image.asset('assets/images/gemini.png'),
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
                    PropertyHeader(
                      address: widget.epc.address,
                      postcode: widget.epc.postcode,
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
            if (_isFinancePanelVisible)
              FinancePanel(onSend: _toggleFinancePanelVisibility),
            if (_isReportPanelVisible)
              Consumer<FinancialController>(
                builder: (context, financialController, child) => ReportPanel(
                  address: widget.epc.address,
                  price: NumberFormat.compactSimpleCurrency(locale: 'en_GB')
                      .format(financialController.currentPrice ?? 0),
                  images: const [], // TODO: Pass the images from the ImageGallery
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
