import 'package:flutter/material.dart';

class FilterScreenBottomNav extends StatelessWidget {
  final Function(int) onTap;

  const FilterScreenBottomNav({super.key, required this.onTap});

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
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
    );
  }
}
