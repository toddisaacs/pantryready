// Run manually: flutter test test/services/openfoodfacts_live_test.dart --verbose
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantryready/services/openfoodfacts_service.dart';

void main() {
  group(
    'OpenFoodFacts Live API Diagnostics',
    skip: 'Manual diagnostic — run explicitly with --verbose',
    () {
      test('Libby green beans — verify category maps to Food, not Water',
          () async {
        final service = OpenFoodFactsService();
        final result = await service.lookupProduct('00037100008414');
        debugPrint('found: ${result.found}');
        debugPrint('name: ${result.name}');
        debugPrint('category: ${result.category}');
        debugPrint('brand: ${result.brand}');
        debugPrint('error: ${result.errorMessage}');
        // If API available, category should not be water-related
      });

      test('Rate limit probe — 5 rapid calls, log any 429 responses', () async {
        final service = OpenFoodFactsService();
        for (var i = 0; i < 5; i++) {
          final result = await service.lookupProduct('00037100008414');
          debugPrint(
            'call $i: found=${result.found} error=${result.errorMessage}',
          );
        }
      });
    },
  );
}
