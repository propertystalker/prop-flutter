import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/screens/opening_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Map Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://www.mapbox.com/images/demos/satellite-v9.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content Overlay
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildAppBar(context),
                  const SizedBox(height: 20),
                  _buildBinocularsCard(context),
                  const SizedBox(height: 20),
                  _buildSearchBar(context),
                  const SizedBox(height: 15),
                  _buildValueRange(context),
                  const SizedBox(height: 20),
                  _buildBoostButton(context),
                  const SizedBox(height: 20),
                  _buildUpliftOptions(context),
                  const SizedBox(height: 100), // To avoid overlap with bottom nav
                ],
              ),
            ),
          ),
          _buildBottomNavBar(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Placeholder for Logo
          const Icon(Icons.remove_red_eye_outlined, color: Colors.blue, size: 40),
          Text(
            'Property Stalker',
            style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.settings, color: Colors.black54, size: 30),
              const SizedBox(width: 10),
              // Placeholder for Profile Picture
              const CircleAvatar(
                radius: 18,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=12'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBinocularsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade300, width: 3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLens(context, 'Property Stalker',
              'Property Stalker is an application that helps users (Investors, Agents, Homeowners & Developers) understand the value uplift potential of a Residential Property'),
          _buildCenterDial(),
          _buildLens(context, 'Boost Potential',
              'Improve your property and reveal its true value'),
        ],
      ),
    );
  }

  Widget _buildLens(BuildContext context, String title, String subtitle) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterDial() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, color: Colors.red.shade400, size: 24),
          const SizedBox(height: 4),
          Icon(Icons.circle, color: Colors.yellow.shade600, size: 24),
          const SizedBox(height: 4),
          Icon(Icons.circle, color: Colors.green.shade400, size: 24),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Address, Postcode, What2Words etc...',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
          ),
          suffixIcon: Icon(Icons.my_location, color: Colors.orange.shade600),
        ),
      ),
    );
  }

  Widget _buildValueRange(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _valueColumn('£266k', 'Low End Value'),
        const Icon(Icons.arrow_forward, color: Colors.black54),
        _valueColumn('£133k', 'Purchase Price', isHighlighted: true),
        const Icon(Icons.arrow_forward, color: Colors.black54),
        _valueColumn('£307k', 'High End Value'),
      ],
    );
  }

  Widget _valueColumn(String value, String label, {bool isHighlighted = false}) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: isHighlighted
              ? BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          child: Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: isHighlighted ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoostButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black87,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OpeningScreen()),
          );
        },
        child: const Text('BOOST PROPERTY POTENTIAL'),
      ),
    );
  }

  Widget _buildUpliftOptions(BuildContext context) {
    final List<Map<String, String>> options = [
      {'title': 'Total Build Cost', 'value': '35K'},
      {'title': 'Total Build Cost', 'value': '35K'},
      {'title': 'Total Investment', 'value': '135K'},
      {'title': 'GDV', 'value': '180K'},
      {'title': 'Profit', 'value': '45K'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Icon(Icons.first_page, size: 18),
              const Icon(Icons.chevron_left, size: 18),
              Text(
                '10 < UPLIFT OPTIONS AVAILABLE > 12',
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const Icon(Icons.chevron_right, size: 18),
              const Icon(Icons.last_page, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          ...options.map((option) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${option['title']}:'),
                  Text(option['value']!),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

   Widget _buildBottomNavBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navBarIcon(Icons.add, Colors.purple),
            _navBarIcon(Icons.attach_money, Colors.green),
            // Central Floating-style Button
            Container(
               width: 56, // Standard FAB size
              height: 56,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)
                ]
              ),
              child: IconButton(
                icon: const Icon(Icons.list, color: Colors.white, size: 30),
                onPressed: () {},
              ),
            ),
            _navBarIcon(Icons.share, Colors.grey),
            _navBarIcon(Icons.search, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _navBarIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
