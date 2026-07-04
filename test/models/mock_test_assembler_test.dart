import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:berlin_nukus/screens/student/mock_test/model/mock_test_assembler.dart';

void main() {
  group('MockTestAssembler.chunk', () {
    test('splits an exact multiple into equal contiguous groups', () {
      final groups = MockTestAssembler.chunk([1, 2, 3, 4, 5, 6], 3);
      expect(groups, [
        [1, 2, 3],
        [4, 5, 6],
      ]);
    });

    test('puts the remainder in a final smaller group', () {
      final groups = MockTestAssembler.chunk([1, 2, 3, 4, 5], 2);
      expect(groups, [
        [1, 2],
        [3, 4],
        [5],
      ]);
    });

    test('preserves order and reconstructs the original when concatenated', () {
      final source = List<int>.generate(23, (i) => i);
      final groups = MockTestAssembler.chunk(source, 5);
      expect(groups.expand((g) => g).toList(), source);
    });

    test('returns a single group when perTest exceeds the length', () {
      final groups = MockTestAssembler.chunk([1, 2], 10);
      expect(groups, [
        [1, 2],
      ]);
    });

    test('returns an empty list for an empty input', () {
      expect(MockTestAssembler.chunk<int>([], 5), isEmpty);
    });

    test('throws when perTest is zero or negative', () {
      expect(() => MockTestAssembler.chunk([1], 0), throwsArgumentError);
      expect(() => MockTestAssembler.chunk([1], -1), throwsArgumentError);
    });
  });

  group('MockTestAssembler.selectIndex', () {
    test('always returns 0 when there is exactly one Test', () {
      final rng = Random(42);
      for (var i = 0; i < 100; i++) {
        expect(MockTestAssembler.selectIndex(rng, 1), 0);
      }
    });

    test('always returns an index within [0, count)', () {
      final rng = Random(7);
      for (var i = 0; i < 1000; i++) {
        final index = MockTestAssembler.selectIndex(rng, 5);
        expect(index, inInclusiveRange(0, 4));
      }
    });

    test('can reach every index across the seed space', () {
      final seen = <int>{};
      for (var seed = 0; seed < 500; seed++) {
        seen.add(MockTestAssembler.selectIndex(Random(seed), 4));
      }
      expect(seen, {0, 1, 2, 3});
    });

    test('throws when count is zero or negative', () {
      final rng = Random(1);
      expect(() => MockTestAssembler.selectIndex(rng, 0), throwsArgumentError);
      expect(() => MockTestAssembler.selectIndex(rng, -3), throwsArgumentError);
    });
  });
}
