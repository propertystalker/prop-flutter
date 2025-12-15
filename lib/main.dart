import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/controllers/company_controller.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/controllers/person_controller.dart';
import 'package:myapp/controllers/user_controller.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/screens/opening_screen.dart';
import 'package:myapp/screens/price_paid_screen.dart';
import 'package:myapp/screens/property_floor_area_screen.dart'
    show PropertyFloorAreaScreen;
import 'package:myapp/utils/constants.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FinancialController()),
        ChangeNotifierProvider(create: (context) => CompanyController()),
        ChangeNotifierProvider(create: (context) => PersonController()),
        ChangeNotifierProvider(create: (context) => UserController()),
      ],
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
        GoRoute(
          path: 'price_paid',
          builder: (BuildContext context, GoRouterState state) {
            final String postcode = state.uri.queryParameters['postcode']!;
            return PricePaidScreen(postcode: postcode);
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
