
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/property_detail_screen.dart';
import 'screens/share_screen.dart';
import 'models/property.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'property',
          builder: (BuildContext context, GoRouterState state) {
            if (state.extra is Property) {
              final Property property = state.extra! as Property;
              return PropertyDetailScreen(property: property);
            } else {
              return const HomeScreen();
            }
          },
        ),
        GoRoute(
          path: 'share',
          builder: (BuildContext context, GoRouterState state) {
            if (state.extra is Property) {
              final Property property = state.extra! as Property;
              return ShareScreen(property: property);
            } else {
              return const HomeScreen();
            }
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Property Data',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
