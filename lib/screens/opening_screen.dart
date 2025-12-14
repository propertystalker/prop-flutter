import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/widgets/filter_screen_bottom_nav.dart';
import 'package:myapp/widgets/property_filter_app_bar.dart';
import '../utils/constants.dart';

class OpeningScreen extends StatelessWidget {
  const OpeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController postcodeController = TextEditingController();

    void searchByPostcode(String postcode) {
      if (postcode.isNotEmpty) {
        context.push('/property_floor_area?postcode=$postcode');
      }
    }

    Widget buildGreyedOutField(String label) {
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

    return Scaffold(
      appBar: PropertyFilterAppBar(
        onLogoTap: () {},
        onAvatarTap: () {},
        onSettingsTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
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
                        borderRadius: BorderRadius.circular(8.0),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/gemini.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    children: [
                      Text('Prev. Price', style: TextStyle(color: accentColor)),
                      SizedBox(height: 8),
                      SizedBox(
                          width: 24,
                          height: 24,
                          child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: trafficRed, width: 2))))),
                      SizedBox(height: 8),
                      SizedBox(
                          width: 24,
                          height: 24,
                          child: DecoratedBox(decoration: BoxDecoration(color: trafficYellow, shape: BoxShape.circle))),
                      SizedBox(height: 8),
                      SizedBox(
                          width: 24,
                          height: 24,
                          child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: trafficGreen, width: 2))))),
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
                      controller: postcodeController,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Address, Postcode, What2Words etc...',
                        hintStyle: TextStyle(color: Colors.white.withAlpha(179)),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () => searchByPostcode(postcodeController.text),
                        ),
                      ),
                      onFieldSubmitted: searchByPostcode,
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('£266k', style: TextStyle(color: accentColor, fontSize: 24)),
                      Text('£270k', style: TextStyle(color: accentColor, fontSize: 36, fontWeight: FontWeight.bold)),
                      Text('£307k', style: TextStyle(color: accentColor, fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    color: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Center(
                      child: Text(
                        'AUTOMATED VALUATION',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildGreyedOutField('Type:'),
                  buildGreyedOutField('Bedrooms:'),
                  buildGreyedOutField('Size:'),
                  buildGreyedOutField('Tenure:'),
                  buildGreyedOutField('Parking Spaces:'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FilterScreenBottomNav(),
    );
  }
}
