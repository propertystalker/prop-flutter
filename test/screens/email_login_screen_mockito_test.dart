import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/screens/company_account_screen.dart';
import 'package:myapp/screens/email_login_screen.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateNiceMocks([
  MockSpec<SupabaseService>(),
  MockSpec<SupabaseClient>(),
  MockSpec<GoTrueClient>(),
])
import 'email_login_screen_mockito_test.mocks.dart';

void main() {
  // 1. Disable the Provider check that interferes with Mockito mocks
  Provider.debugCheckInvalidValueType = null;

  late MockSupabaseService mockSupabaseService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();

    when(mockSupabaseService.client).thenReturn(mockSupabaseClient);
    when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
  });

  testWidgets('Email login screen should show loading indicator and navigate on success', (WidgetTester tester) async {
    final authCompleter = Completer<AuthResponse>();
    final user = User(
      id: 'test-user-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );
    final session = Session(
        accessToken: 'test-token',
        tokenType: 'bearer',
        user: user,
      );

    when(mockGoTrueClient.onAuthStateChange).thenAnswer((_) => Stream.value(
          AuthState(
            AuthChangeEvent.signedIn,
            session,
          ), 
        ));

    when(mockSupabaseService.signInWithPassword(any, any))
        .thenAnswer((_) => authCompleter.future);
    
    when(mockSupabaseService.getCompany(any)).thenThrow(Exception('Company not found'));
    when(mockSupabaseService.getPerson(any)).thenThrow(Exception('Person not found'));

    // 2. Use a Provider that is compatible with mocks
    await tester.pumpWidget(
      Provider<SupabaseService>.value(
        value: mockSupabaseService,
        child: const MaterialApp(
          home: EmailLoginScreen(),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('email-field')), 'test@test.com');
    await tester.enterText(find.byKey(const Key('password-field')), 'password');
    await tester.tap(find.byKey(const Key('login-button')));

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget, reason: "Loading indicator should be visible after tapping login.");

    authCompleter.complete(AuthResponse(
      user: user,
      session: session,
    ));

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    
    expect(find.byType(CompanyAccountScreen), findsOneWidget);

    verify(mockSupabaseService.signInWithPassword('test@test.com', 'password')).called(1);
  });
}
