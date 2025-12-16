import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controllers/company_controller.dart';
import 'package:myapp/controllers/finance_proposal_request_controller.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/controllers/price_paid_controller.dart';
import 'package:myapp/controllers/property_floor_area_filter_controller.dart';
import 'package:myapp/controllers/send_report_request_controller.dart';
import 'package:myapp/widgets/company_account.dart';
import 'package:myapp/widgets/person_account.dart';
import 'package:myapp/widgets/property_details/image_gallery.dart';
import 'package:myapp/widgets/property_details/price_history.dart';
import 'package:myapp/widgets/property_details/property_header.dart';
import 'package:myapp/widgets/property_details/property_stats.dart';
import 'package:provider/provider.dart';
import '../widgets/development_scenarios.dart';
import '../widgets/financial_summary.dart';
import '../widgets/filter_screen_bottom_nav.dart';
import '../widgets/finance_panel.dart';
import '../widgets/property_filter_app_bar.dart';
import '../widgets/report_panel.dart';
import '../widgets/traffic_light_indicator.dart';
import '../models/property_floor_area.dart';
import 'report_sent_screen.dart';

class PropertyFloorAreaFilterScreen extends StatefulWidget {
  final KnownFloorArea area;
  final String postcode;

  const PropertyFloorAreaFilterScreen(
      {super.key, required this.area, required this.postcode});

  @override
  State<PropertyFloorAreaFilterScreen> createState() =>
      _PropertyFloorAreaFilterScreenState();
}

class _PropertyFloorAreaFilterScreenState
    extends State<PropertyFloorAreaFilterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPriceHistory();
    });
  }

  void _fetchPriceHistory() {
    final addressParts = widget.area.address.split(',');
    final houseNumber = addressParts.isNotEmpty ? addressParts.first.trim() : '';

    if (houseNumber.isNotEmpty) {
      final pricePaidController =
          Provider.of<PricePaidController>(context, listen: false);
      pricePaidController.fetchPricePaidHistoryForProperty(
          widget.postcode, houseNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final financialController =
        Provider.of<FinancialController>(context, listen: false);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PropertyFloorAreaFilterController(
            postcode: widget.postcode,
            habitableRooms: widget.area.habitableRooms,
            financialController: financialController,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FinanceProposalRequestController(),
        ),
        ChangeNotifierProvider(
          create: (_) => SendReportRequestController(),
        ),
      ],
      child: Consumer<PropertyFloorAreaFilterController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: PropertyFilterAppBar(
              onLogoTap: controller.toggleCompanyAccountVisibility,
              onAvatarTap: controller.togglePersonAccountVisibility,
            ),
            body: Column(
              children: [
                if (controller.isCompanyAccountVisible)
                  CompanyAccount(
                    onCompanyChanged: (name) => Provider.of<CompanyController>(context, listen: false).setCompanyName(name),
                    onSave: controller.hideCompanyAccount,
                  ),
                if (controller.isPersonAccountVisible)
                  PersonAccount(
                    onSave: controller.hidePersonAccount,
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
                                isLoading: controller.isLoadingHistoricalPrice,
                                price: controller.historicalPrice,
                                error: controller.historicalPriceError,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: controller.pickImages,
                                  child: Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blue, width: 2),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: const ImageGallery(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        PropertyHeader(
                          address: widget.area.address,
                          postcode: widget.postcode,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 16),
                              PropertyStats(
                                squareFeet: widget.area.squareFeet,
                                habitableRooms: widget.area.habitableRooms,
                              ),
                              const Divider(height: 32),
                              Consumer<FinancialController>(
                                builder: (context, financialController, child) => DevelopmentScenarios(
                                  selectedScenario: financialController.houseScenarios[financialController.selectedScenarioIndex],
                                  onPrevious: () => financialController.previousScenario(widget.area.address.toLowerCase().contains('flat')),
                                  onNext: () => financialController.nextScenario(widget.area.address.toLowerCase().contains('flat')),
                                  gdv: financialController.gdv,
                                  totalCost: financialController.totalCost,
                                  uplift: financialController.uplift,
                                ),
                              ),
                              const Divider(height: 32),
                               Consumer<FinancialController>(
                                builder: (context, financialController, child) => FinancialSummary(
                                  gdv: financialController.gdv,
                                  totalCost: financialController.totalCost,
                                  uplift: financialController.uplift,
                                  roi: financialController.roi,
                                ),
                              ),
                              const Divider(height: 32),
                              const PriceHistory(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (controller.isFinancePanelVisible)
                  FinancePanel(
                    onSend: controller.hideFinancePanel,
                  ),
                if (controller.isReportPanelVisible)
                  Consumer<FinancialController>(
                    builder: (context, financialController, child) => ReportPanel(
                      address: widget.area.address,
                      price: NumberFormat.compactSimpleCurrency(locale: 'en_GB').format(financialController.currentPrice),
                      images: controller.images,
                      gdv: financialController.gdv,
                      totalCost: financialController.totalCost,
                      uplift: financialController.uplift,
                      onSend: () {
                        controller.hideReportPanel();
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
              if (index == 0) {
                controller.toggleFinancePanelVisibility();
              }
              if (index == 1) {
                controller.pickImages();
              }
              if (index == 2) {
                controller.toggleReportPanelVisibility();
              }
            }),
          );
        },
      ),
    );
  }
}
