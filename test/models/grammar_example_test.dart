import 'package:flutter_test/flutter_test.dart';
import 'package:berlin_nukus/models/grammar_example.dart';

void main() {
  group('GrammarExample', () {
    test('should create with required fields', () {
      final example = GrammarExample(
        german: 'Ich bin Student.',
        uzbek: 'Men talabaman.',
      );

      expect(example.german, 'Ich bin Student.');
      expect(example.uzbek, 'Men talabaman.');
      expect(example.note, isNull);
    });

    test('should create with optional note', () {
      final example = GrammarExample(
        german: 'Der Mann liest ein Buch.',
        uzbek: 'Erkak kitob o\'qiyapti.',
        note: 'der - erkak jins artikli',
      );

      expect(example.german, 'Der Mann liest ein Buch.');
      expect(example.uzbek, 'Erkak kitob o\'qiyapti.');
      expect(example.note, 'der - erkak jins artikli');
    });

    test('should serialize to JSON correctly', () {
      final example = GrammarExample(
        german: 'Der Mann',
        uzbek: 'Erkak',
        note: 'der - erkak jins artikli',
      );

      final json = example.toJson();

      expect(json['german'], 'Der Mann');
      expect(json['uzbek'], 'Erkak');
      expect(json['note'], 'der - erkak jins artikli');
    });

    test('should serialize to JSON without note when null', () {
      final example = GrammarExample(
        german: 'Der Mann',
        uzbek: 'Erkak',
      );

      final json = example.toJson();

      expect(json['german'], 'Der Mann');
      expect(json['uzbek'], 'Erkak');
      expect(json.containsKey('note'), isFalse);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'german': 'Die Frau',
        'uzbek': 'Ayol',
        'note': 'die - ayol jins artikli',
      };

      final example = GrammarExample.fromJson(json);

      expect(example.german, 'Die Frau');
      expect(example.uzbek, 'Ayol');
      expect(example.note, 'die - ayol jins artikli');
    });

    test('should deserialize from JSON without note', () {
      final json = {
        'german': 'Das Kind',
        'uzbek': 'Bola',
      };

      final example = GrammarExample.fromJson(json);

      expect(example.german, 'Das Kind');
      expect(example.uzbek, 'Bola');
      expect(example.note, isNull);
    });

    test('should support JSON round-trip', () {
      final original = GrammarExample(
        german: 'Ich lerne Deutsch.',
        uzbek: 'Men nemis tilini o\'rganaman.',
        note: 'lerne - o\'rganmoq fe\'li',
      );

      final json = original.toJson();
      final restored = GrammarExample.fromJson(json);

      expect(restored, equals(original));
    });

    test('should support JSON round-trip without note', () {
      final original = GrammarExample(
        german: 'Guten Tag!',
        uzbek: 'Xayrli kun!',
      );

      final json = original.toJson();
      final restored = GrammarExample.fromJson(json);

      expect(restored, equals(original));
    });

    test('should implement equality correctly', () {
      final example1 = GrammarExample(
        german: 'Hallo',
        uzbek: 'Salom',
        note: 'salomlashish',
      );

      final example2 = GrammarExample(
        german: 'Hallo',
        uzbek: 'Salom',
        note: 'salomlashish',
      );

      final example3 = GrammarExample(
        german: 'Hallo',
        uzbek: 'Salom',
      );

      expect(example1, equals(example2));
      expect(example1, isNot(equals(example3)));
    });

    test('should implement hashCode correctly', () {
      final example1 = GrammarExample(
        german: 'Hallo',
        uzbek: 'Salom',
        note: 'salomlashish',
      );

      final example2 = GrammarExample(
        german: 'Hallo',
        uzbek: 'Salom',
        note: 'salomlashish',
      );

      expect(example1.hashCode, equals(example2.hashCode));
    });

    test('should implement toString correctly', () {
      final example = GrammarExample(
        german: 'Hallo',
        uzbek: 'Salom',
        note: 'salomlashish',
      );

      final str = example.toString();

      expect(str, contains('GrammarExample'));
      expect(str, contains('Hallo'));
      expect(str, contains('Salom'));
      expect(str, contains('salomlashish'));
    });
  });
}
