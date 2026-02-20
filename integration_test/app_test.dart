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

      // Generous timeout for splash, Firebase, mock data, UI
      await tester.pumpAndSettle(const Duration(seconds: 12));

      // === Exact, unique matchers from your real UI ===
      expect(find.text('8 items'), findsOneWidget); // summary
      expect(find.text('2 low stock'), findsOneWidget);
      expect(find.text('0 expiring'), findsOneWidget);

      expect(find.text('Search items...'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      // Bottom navigation bar
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Sample inventory item (proves list loaded)
      expect(find.text('Canned Beans'), findsOneWidget);

      // Main action icon
      expect(find.byIcon(Icons.qr_code_scanner), findsAtLeast(1));

      print('✅ SUCCESS: PantryReady full E2E test passed on Simulator!');
    });
  });
}
