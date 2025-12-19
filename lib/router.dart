import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/admin_screen.dart';
import 'package:myapp/screens/epc_screen.dart';
import 'package:myapp/screens/opening_screen.dart';
import 'package:myapp/screens/price_paid_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/property_floor_area_screen.dart'
    show PropertyFloorAreaScreen;
import 'package:myapp/utils/constants.dart';

final GoRouter router = GoRouter(
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
            // This line ensures that if if 'houseNumber' is missing from the URL,
            // a non-null empty string is passed to the screen, satisfying the
            // `required` constraint.
            final String houseNumber =
                state.uri.queryParameters['houseNumber'] ?? '';
            return PricePaidScreen(postcode: postcode, houseNumber: houseNumber);
          },
        ),
        GoRoute(
          path: 'epc',
          builder: (BuildContext context, GoRouterState state) {
            final String postcode = state.uri.queryParameters['postcode']!;
            final String? houseNumber = state.uri.queryParameters['houseNumber'];
            return EpcScreen(postcode: postcode, houseNumber: houseNumber);
          },
        ),
      ],
    ),
  ],
);
