import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pantryready/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PantryReady End-to-End Tests', () {
    testWidgets('Full app launch + home screen loads with mock data', (
      tester,
    ) async {
      app.main();

      // Generous timeout for Firebase init, mock data service, and UI render.
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Stats bar is present — check structure, not exact counts, so the test
      // survives mock data changes without being updated.
      expect(find.textContaining('items'), findsOneWidget);
      expect(find.textContaining('low stock'), findsOneWidget);
      expect(find.textContaining('expiring'), findsOneWidget);

      // Search bar and Add button
      expect(find.text('Search items...'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      // All four bottom navigation tabs
      expect(find.text('Pantry'), findsOneWidget);
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // At least one inventory item rendered (confirms data loaded)
      expect(find.text('Canned Beans'), findsOneWidget);

      // Scanner icon in nav bar
      expect(find.byIcon(Icons.qr_code_scanner), findsAtLeastNWidgets(1));

      debugPrint('✅ PantryReady E2E smoke test passed.');
    });
  });
}
