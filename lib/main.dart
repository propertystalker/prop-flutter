
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myapp/controllers/company_controller.dart';
import 'package:myapp/controllers/epc_controller.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/controllers/gdv_controller.dart';
import 'package:myapp/controllers/person_controller.dart';
import 'package:myapp/controllers/price_paid_controller.dart';
import 'package:myapp/controllers/report_session_controller.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/router.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: superbaseUrl,
    anonKey: superbaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SupabaseService()),
        ChangeNotifierProvider(create: (context) => FinancialController()),
        ChangeNotifierProvider(create: (context) => EpcController()),
        ChangeNotifierProvider(create: (context) => PricePaidController()),
        ChangeNotifierProvider(create: (context) => PersonController()),
        ChangeNotifierProvider(create: (context) => CompanyController()),
        ChangeNotifierProvider(create: (context) => GdvController()),
        ChangeNotifierProvider(create: (context) => ReportSessionController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Property Data',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
