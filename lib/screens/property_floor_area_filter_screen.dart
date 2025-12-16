import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controllers/company_controller.dart';
import 'package:myapp/controllers/finance_proposal_request_controller.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/controllers/person_controller.dart';
import 'package:myapp/controllers/price_paid_controller.dart';
import 'package:myapp/controllers/property_floor_area_filter_controller.dart';
import 'package:myapp/controllers/send_report_request_controller.dart';
import 'package:myapp/widgets/company_account.dart';
import 'package:myapp/widgets/person_account.dart';
import 'package:provider/provider.dart';
import '../widgets/development_scenarios.dart';
import '../widgets/financial_summary.dart';
import '../widgets/filter_screen_bottom_nav.dart';
import '../widgets/finance_panel.dart';
import '../widgets/property_filter_app_bar.dart';
import '../widgets/report_panel.dart';
import '../widgets/traffic_light_indicator.dart';
import '../models/property_floor_area.dart';
import '../utils/constants.dart';
import 'property_floor_area_screen.dart';
import 'report_sent_screen.dart';

class PropertyFloorAreaFilterScreen extends StatefulWidget {
  final KnownFloorArea area;
  final String postcode;

  const PropertyFloorAreaFilterScreen(
      {super.key, required this.area, required this.postcode});

  @override
  State<PropertyFloorAreaFilterScreen> createState() => _PropertyFloorAreaFilterScreenState();
}

class _PropertyFloorAreaFilterScreenState extends State<PropertyFloorAreaFilterScreen> {

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
      final pricePaidController = Provider.of<PricePaidController>(context, listen: false);
      pricePaidController.fetchPricePaidHistoryForProperty(widget.postcode, houseNumber);
    }
  }

  void _searchByPostcode(BuildContext context, String postcode) {
    if (postcode.isNotEmpty) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PropertyFloorAreaScreen(
            postcode: postcode,
            apiKey: apiKey,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final financialController = Provider.of<FinancialController>(context, listen: false);
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
      child: Consumer6<PropertyFloorAreaFilterController, FinancialController, CompanyController, PersonController, FinanceProposalRequestController, SendReportRequestController>(
        builder: (context, controller, financialController, companyController, personController, financeRequestController, sendReportRequestController, child) {
          final postcodeController = TextEditingController(text: widget.postcode);

          return Scaffold(
            appBar: PropertyFilterAppBar(
              onLogoTap: controller.toggleCompanyAccountVisibility,
              onAvatarTap: controller.togglePersonAccountVisibility,
            ),
            body: Column(
              children: [
                if (controller.isCompanyAccountVisible)
                  CompanyAccount(
                    onCompanyChanged: (name) => companyController.setCompanyName(name),
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
                                    child: _buildImageGallery(controller),
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
                                child: Column(
                                  children: [
                                    Text(
                                      widget.area.address,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: postcodeController,
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
                                              _searchByPostcode(context, postcodeController.text),
                                        ),
                                      ),
                                      onFieldSubmitted: (value) => _searchByPostcode(context, value),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildEditablePrice(context, controller, financialController),
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
                                selectedScenario: financialController.houseScenarios[financialController.selectedScenarioIndex],
                                onPrevious: () => financialController.previousScenario(widget.area.address.toLowerCase().contains('flat')),
                                onNext: () => financialController.nextScenario(widget.area.address.toLowerCase().contains('flat')),
                                gdv: financialController.gdv,
                                totalCost: financialController.totalCost,
                                uplift: financialController.uplift,
                              ),
                              const Divider(height: 32),
                              FinancialSummary(
                                gdv: financialController.gdv,
                                totalCost: financialController.totalCost,
                                uplift: financialController.uplift,
                                roi: financialController.roi,
                              ),
                              const Divider(height: 32),
                              _buildPriceHistorySection(), // New section added here
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
                  ReportPanel(
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

  Widget _buildImageGallery(PropertyFloorAreaFilterController controller) {
    if (controller.images.isEmpty) {
      return const Center(child: Text('Your photos will appear here'));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: controller.pageController,
          itemCount: controller.images.length,
          onPageChanged: controller.onPageChanged,
          itemBuilder: (context, index) {
            final image = controller.images[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: kIsWeb
                  ? Image.network(image.path, fit: BoxFit.cover)
                  : Image.file(File(image.path), fit: BoxFit.cover),
            );
          },
        ),
        Positioned(
            top: 8,
            left: 8,
            child: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.white),
                onPressed: () => controller.removeImage(controller.currentImageIndex))),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(153),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              '${controller.currentImageIndex + 1} / ${controller.images.length}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
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
                  if (controller.currentImageIndex > 0) {
                    controller.pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onPressed: () {
                  if (controller.currentImageIndex < controller.images.length - 1) {
                    controller.pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditablePrice(BuildContext context, PropertyFloorAreaFilterController controller, FinancialController financialController) {
    final currencyFormat = NumberFormat.compactSimpleCurrency(locale: 'en_GB');
    final priceController = TextEditingController();

    if (controller.isLoadingPrice) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    if (controller.currentPriceError != null) {
      return const Text(
        'Error: Please try again',
        style: TextStyle(color: Colors.white, fontSize: 18),
      );
    }

    if (controller.isEditingPrice) {
      priceController.text = financialController.currentPrice.toStringAsFixed(0);
      return Container(
        color: editablePriceColor,
        width: 200,
        child: TextField(
          controller: priceController,
          focusNode: controller.priceFocusNode,
          keyboardType: TextInputType.number,
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(8.0),
          ),
          onSubmitted: controller.updatePrice,
          onTapOutside: (_) => controller.updatePrice(priceController.text),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          controller.editPrice();
          priceController.text = financialController.currentPrice.toStringAsFixed(0);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: editablePriceColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            currencyFormat.format(financialController.currentPrice),
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }
  }

  Widget _buildPriceHistorySection() {
    return Consumer<PricePaidController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error != null) {
          return Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Price History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.priceHistory.isEmpty) {
          return const SizedBox.shrink(); // Don't show the section if there's no history
        }

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Price History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.priceHistory.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = controller.priceHistory[index];
                    final formattedDate = DateFormat.yMMMMd().format(item.transactionDate);
                    final formattedPrice = NumberFormat.simpleCurrency(locale: 'en_GB').format(item.amount);
                    return ListTile(
                      title: Text(formattedPrice, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Sold on $formattedDate'),
                      trailing: Text(item.propertyType, style: Theme.of(context).textTheme.bodySmall),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
