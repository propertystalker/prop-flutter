import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/planning_application.dart';
import 'package:myapp/screens/admin_screen.dart';
import 'package:myapp/screens/epc_screen.dart';
import 'package:myapp/screens/opening_screen.dart';
import 'package:myapp/screens/payment_success_screen.dart'; // Import the new screen
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/report_screen.dart';
import 'package:myapp/screens/scenario_selection_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:developer' as developer;

final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);

final GoRouter router = GoRouter(
  observers: [observer],
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const OpeningScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreen();
          },
        ),
        GoRoute(
          path: 'admin',
          builder: (BuildContext context, GoRouterState state) {
            return const AdminScreen();
          },
        ),
         GoRoute(
          path: 'payment-success', // Add the new route
          builder: (BuildContext context, GoRouterState state) {
            return const PaymentSuccessScreen();
          },
        ),
        GoRoute(
          path: 'epc',
          builder: (BuildContext context, GoRouterState state) {
            final String postcode = state.uri.queryParameters['postcode']!;
            final String? houseNumber = state.uri.queryParameters['houseNumber'];
            final String? flatNumber = state.uri.queryParameters['flatNumber'];
            return EpcScreen(
              postcode: postcode,
              houseNumber: houseNumber,
              flatNumber: flatNumber,
            );
          },
        ),
        GoRoute(
          path: 'select-scenarios/:propertyId',
          builder: (BuildContext context, GoRouterState state) {
            final String propertyId = state.pathParameters['propertyId']!;
            return ScenarioSelectionScreen(propertyId: propertyId);
          },
        ),
        GoRoute(
          path: 'report/:propertyId',
          builder: (BuildContext context, GoRouterState state) {
            final String propertyId = state.pathParameters['propertyId']!;

            // Log the received extra data for debugging
            developer.log('Navigating to ReportScreen. Received extra: ${state.extra}', name: 'router.report');

            final extraData = state.extra as Map<String, dynamic>? ?? {};
            final List<String> selectedScenarios = List<String>.from(extraData['scenarios'] ?? []);
            final List<PlanningApplication> propertyDataApplications = List<PlanningApplication>.from(extraData['propertyDataApplications'] ?? []);
            final List<PlanningApplication> planitApplications = List<PlanningApplication>.from(extraData['planitApplications'] ?? []);

            return ReportScreen(
              propertyId: propertyId,
              selectedScenarios: selectedScenarios,
              propertyDataApplications: propertyDataApplications,
              planitApplications: planitApplications,
            );
          },
        ),
      ],
    ),
  ],
);
