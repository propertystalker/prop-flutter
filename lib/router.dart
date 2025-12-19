import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/admin_screen.dart';
import 'package:myapp/screens/epc_screen.dart';
import 'package:myapp/screens/opening_screen.dart';
import 'package:myapp/screens/price_paid_screen.dart';
import 'package:myapp/screens/profile_screen.dart';

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
          path: 'price_paid',
          builder: (BuildContext context, GoRouterState state) {
            final String postcode = state.uri.queryParameters['postcode']!;
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
