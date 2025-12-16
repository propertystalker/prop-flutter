import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/controllers/property_floor_area_filter_controller.dart';
import 'package:myapp/screens/property_floor_area_screen.dart';
import 'package:myapp/utils/constants.dart';
import 'package:provider/provider.dart';

class PropertyHeader extends StatelessWidget {
  final String address;
  final String postcode;

  const PropertyHeader({
    super.key,
    required this.address,
    required this.postcode,
  });

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
    final controller = Provider.of<PropertyFloorAreaFilterController>(context);
    final financialController = Provider.of<FinancialController>(context);
    final postcodeController = TextEditingController(text: postcode);

    return Container(
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
                  address,
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
    );
  }

  Widget _buildEditablePrice(BuildContext context,
      PropertyFloorAreaFilterController controller, FinancialController financialController) {
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
}
