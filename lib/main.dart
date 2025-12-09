
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/property.dart';
import 'screens/home_screen.dart';
import 'screens/property_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/property',
      builder: (context, state) {
        final property = state.extra as Property;
        return PropertyDetailScreen(property: property);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Property Data App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    );
  }
}
