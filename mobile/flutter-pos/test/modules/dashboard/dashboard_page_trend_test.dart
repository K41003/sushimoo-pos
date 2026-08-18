// test/modules/dashboard/dashboard_page_trend_test.dart
//
// Regression tests for the crash reported on the Admin Dashboard:
//
//   type 'List<dynamic>' is not a subtype of type 'Map<dynamic, dynamic>?'
//   in type cast
//
// Root cause: `/dashboard/admin` can return `salesTrend` as either a
// keyed Map or a List of {date, total} objects. The page previously did
// `(d['salesTrend'] as Map? ?? {})`, which throws whenever the backend
// sends the List form. `normalizeTrend()` fixes this by accepting both
// shapes.
//
// Run with: flutter test test/modules/dashboard/dashboard_page_trend_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sushimoo_pos/modules/dashboard/views/dashboard_page.dart';

void main() {
  group('normalizeTrend', () {
    test(
      'REGRESSION: List-of-objects salesTrend (the shape that crashed the app) '
      'is parsed into a Map without throwing',
      () {
        final backendPayload = {
          'salesTrend': [
            {'date': '2026-08-10', 'total': 120000},
            {'date': '2026-08-11', 'total': 95000},
          ],
        };

        expect(
          () => normalizeTrend(backendPayload['salesTrend']),
          returnsNormally,
        );

        final result = normalizeTrend(backendPayload['salesTrend']);
        expect(result, isA<Map<String, num>>());
        expect(result.length, 2);
        expect(result['2026-08-10'], 120000);
        expect(result['2026-08-11'], 95000);
      },
    );

    test('demonstrates the ORIGINAL bug would throw (naive cast)', () {
      final listPayload = [
        {'date': '2026-08-10', 'total': 120000},
      ];

      // This mirrors the old, buggy line: `(raw as Map? ?? {})`.
      // `as Map?` only tolerates null; a List still fails the cast.
      expect(
        () => (listPayload as dynamic) as Map?,
        throwsA(isA<TypeError>()),
      );
    });

    test('Map-form salesTrend (legacy/alternate backend shape) still works', () {
      final backendPayload = {
        'salesTrend': {'2026-08-10': 120000, '2026-08-11': 95000},
      };

      final result = normalizeTrend(backendPayload['salesTrend']);
      expect(result, {'2026-08-10': 120000, '2026-08-11': 95000});
    });

    test('Map-form with numeric-string values is coerced to num', () {
      final result = normalizeTrend({'2026-08-10': '120000'});
      expect(result['2026-08-10'], 120000);
      expect(result['2026-08-10'], isA<num>());
    });

    test('List-form with alternate key names (label/tanggal/value/sales) is handled', () {
      final result = normalizeTrend([
        {'label': '2026-08-10', 'value': 120000},
        {'tanggal': '2026-08-11', 'sales': 95000},
      ]);
      expect(result['2026-08-10'], 120000);
      expect(result['2026-08-11'], 95000);
    });

    test('null salesTrend returns an empty map, does not throw', () {
      expect(normalizeTrend(null), isEmpty);
    });

    test('missing key (absent from response map) returns an empty map', () {
      final backendPayload = <String, dynamic>{'totalSales': 500000};
      expect(normalizeTrend(backendPayload['salesTrend']), isEmpty);
    });

    test('malformed list entries (non-Map items) are skipped, not thrown', () {
      final result = normalizeTrend([
        {'date': '2026-08-10', 'total': 120000},
        'not-a-map', // malformed entry from a flaky API
        42,
      ]);
      expect(result.length, 1);
      expect(result['2026-08-10'], 120000);
    });

    test('empty list returns an empty map', () {
      expect(normalizeTrend(<dynamic>[]), isEmpty);
    });

    test('empty map returns an empty map', () {
      expect(normalizeTrend(<String, dynamic>{}), isEmpty);
    });

    test('unsupported type (e.g. String) returns an empty map instead of throwing', () {
      expect(normalizeTrend('unexpected-string'), isEmpty);
    });
  });
}
