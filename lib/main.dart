import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/screens/opening_screen.dart';
import 'package:myapp/screens/property_floor_area_screen.dart' show PropertyFloorAreaScreen;
import 'package:myapp/utils/constants.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FinancialController(),
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const OpeningScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'property_floor_area',
          builder: (BuildContext context, GoRouterState state) {
            final String postcode = state.uri.queryParameters['postcode']!;
            return PropertyFloorAreaScreen(postcode: postcode, apiKey: apiKey);
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
