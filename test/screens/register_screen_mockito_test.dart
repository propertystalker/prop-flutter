
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/screens/person_account_screen.dart';
import 'package:myapp/screens/register_screen.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateNiceMocks([
  MockSpec<SupabaseService>(),
  MockSpec<SupabaseClient>(),
  MockSpec<GoTrueClient>(),
])
import 'register_screen_mockito_test.mocks.dart';

void main() {
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

  testWidgets('Register screen should show loading indicator and navigate on success', (WidgetTester tester) async {
    final authCompleter = Completer<AuthResponse>();
    final user = User(
      id: 'new-user-id',
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

    when(mockSupabaseService.signUp(any, any, data: anyNamed('data')))
        .thenAnswer((_) => authCompleter.future);

    await tester.pumpWidget(
      Provider<SupabaseService>.value(
        value: mockSupabaseService,
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    // Enter text in the fields
    await tester.enterText(find.byKey(const Key('email-field')), 'test@test.com');
    await tester.enterText(find.byKey(const Key('company-field')), 'Test Company');
    await tester.enterText(find.byKey(const Key('password-field')), 'password');
    
    // Tap the register button
    await tester.tap(find.byType(ElevatedButton));

    // Pump to show the loading indicator
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the signup process
    authCompleter.complete(AuthResponse(
      user: user,
      session: session,
    ));

    // Pump and settle for navigation
    await tester.pumpAndSettle();

    // Verify UI changes
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(PersonAccountScreen), findsOneWidget);

    // Verify mock interaction
    verify(mockSupabaseService.signUp(
      'test@test.com', 
      'password', 
      data: {'company': 'Test Company'}
    )).called(1);
  });
}
