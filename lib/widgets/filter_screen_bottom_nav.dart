import 'package:flutter/material.dart';

class FilterScreenBottomNav extends StatefulWidget {
  final Function(int)? onTap;

  const FilterScreenBottomNav({super.key, this.onTap});

  @override
  State<FilterScreenBottomNav> createState() => _FilterScreenBottomNavState();
}

class _FilterScreenBottomNavState extends State<FilterScreenBottomNav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Text('£', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.share), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: ''),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped,
    );
  }
}
