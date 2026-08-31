import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/admin/widgets/staleness_banner.dart';

void main() {
  group('isStale', () {
    final reference = DateTime(2026, 8, 31, 12, 0, 0);

    test('a fresh fetch is not stale', () {
      final lastFetched = reference.subtract(const Duration(seconds: 5));
      expect(isStale(lastFetched, now: reference), isFalse);
    });

    test('a fetch older than the threshold is stale', () {
      final lastFetched = reference.subtract(const Duration(seconds: 90));
      expect(isStale(lastFetched, now: reference), isTrue);
    });

    test('exactly at the threshold is not yet stale', () {
      final lastFetched = reference.subtract(const Duration(seconds: 60));
      expect(isStale(lastFetched, now: reference), isFalse);
    });

    test('one second past the threshold is stale', () {
      final lastFetched = reference.subtract(const Duration(seconds: 61));
      expect(isStale(lastFetched, now: reference), isTrue);
    });

    test('respects a custom threshold', () {
      final lastFetched = reference.subtract(const Duration(seconds: 15));
      expect(isStale(lastFetched, now: reference, threshold: const Duration(seconds: 10)), isTrue);
      expect(isStale(lastFetched, now: reference, threshold: const Duration(seconds: 20)), isFalse);
    });
  });
}
