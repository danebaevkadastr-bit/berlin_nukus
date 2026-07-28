import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'gemini_live_prompt.dart';

class DictionaryEntry {
  final String word;
  final String definition;

  const DictionaryEntry({
    required this.word,
    required this.definition,
  });
}

class KarakalpakDictionaryService {
  static final KarakalpakDictionaryService _instance = KarakalpakDictionaryService._internal();
  factory KarakalpakDictionaryService() => _instance;
  KarakalpakDictionaryService._internal();

  List<DictionaryEntry> _entries = [];
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final data = await rootBundle.loadString('assets/ruqq/sozlik_clean.txt');
      final lines = data.split('\n');
      final RegExp splitRegExp = RegExp(r'\s+[\u2014\u2013-]\s+');
      
      final List<DictionaryEntry> temp = [];
      for (final line in lines) {
        final cleanLine = line.trim();
        if (cleanLine.isEmpty) continue;
        
        final parts = cleanLine.split(splitRegExp);
        if (parts.length >= 2) {
          final word = parts[0].trim();
          final definition = parts.sublist(1).join(' — ').trim();
          temp.add(DictionaryEntry(word: word, definition: definition));
        }
      }
      _entries = temp;
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error loading Karakalpak dictionary: $e');
    }
  }

  /// Searches the dictionary. Returns up to 50 results.
  List<DictionaryEntry> search(String query) {
    if (!_isInitialized || query.isEmpty) return [];
    final lowerQuery = query.toLowerCase().trim();
    
    // Search priorities
    final List<DictionaryEntry> exactMatches = [];
    final List<DictionaryEntry> prefixMatches = [];
    final List<DictionaryEntry> substringMatches = [];
    final List<DictionaryEntry> definitionMatches = [];

    for (final entry in _entries) {
      final entryWordLower = entry.word.toLowerCase();
      final entryDefLower = entry.definition.toLowerCase();

      if (entryWordLower == lowerQuery) {
        exactMatches.add(entry);
      } else if (entryWordLower.startsWith(lowerQuery)) {
        prefixMatches.add(entry);
      } else if (entryWordLower.contains(lowerQuery)) {
        substringMatches.add(entry);
      } else if (entryDefLower.contains(lowerQuery)) {
        definitionMatches.add(entry);
      }
    }

    final all = [
      ...exactMatches,
      ...prefixMatches,
      ...substringMatches,
      ...definitionMatches,
    ];

    // Deduplicate and take top 50
    final List<DictionaryEntry> result = [];
    final Set<String> seen = {};
    for (final entry in all) {
      if (!seen.contains(entry.word)) {
        seen.add(entry.word);
        result.add(entry);
        if (result.length >= 50) break;
      }
    }
    
    return result;
  }

  /// Generates a thematic glossary for a Voice AI mode.
  Future<String> getGlossaryForMode(VoiceAiMode mode) async {
    await init();
    final List<String> keywords;
    switch (mode) {
      case VoiceAiMode.magazin:
        keywords = ['buy', 'sell', 'price', 'store', 'shop', 'money', 'cost', 'pay', 'customer', 'receipt', 'supermarket', 'groceries', 'market', 'cashier'];
        break;
      case VoiceAiMode.politsiya:
        keywords = ['pass', 'passport', 'airport', 'border', 'police', 'visa', 'officer', 'security', 'customs', 'control', 'document', 'law', 'ticket', 'fine'];
        break;
      case VoiceAiMode.ijara:
        keywords = ['rent', 'house', 'room', 'flat', 'apartment', 'lease', 'tenant', 'landlord', 'key', 'deposit', 'contract', 'renting'];
        break;
      case VoiceAiMode.hospital:
        keywords = ['doctor', 'sick', 'pain', 'hospital', 'medicine', 'ill', 'nurse', 'health', 'appointment', 'pharmacy', 'patient', 'headache'];
        break;
      case VoiceAiMode.cafe:
        keywords = ['waiter', 'menu', 'bill', 'order', 'food', 'drink', 'coffee', 'tea', 'cafe', 'restaurant', 'taste', 'eat', 'dinner'];
        break;
      default:
        return '';
    }

    final List<String> glossaryLines = [];
    final Set<String> seen = {};

    for (final entry in _entries) {
      final entryDefLower = entry.definition.toLowerCase();
      for (final kw in keywords) {
        if (entryDefLower.contains(kw)) {
          final cleanWord = entry.word.trim();
          if (!seen.contains(cleanWord)) {
            seen.add(cleanWord);
            glossaryLines.add('- ${entry.word} = ${entry.definition}');
          }
          break; // match found, go to next entry
        }
      }
      if (glossaryLines.length >= 30) break;
    }

    return glossaryLines.join('\n');
  }
}
