import 'package:flutter/material.dart';
import '../../../services/ai_service.dart';
import '../../../services/tts_service.dart';
import '../../../services/stt_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/theme_manager.dart';
import '../../../widgets/decorative_pattern_background.dart';
import '../../../widgets/gamified_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/vocabulary_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _textController = TextEditingController();
  final TTSService _ttsService = TTSService();
  final STTService _sttService = STTService();
  final ValueNotifier<bool> _ttsPlaying = ValueNotifier(false);
  Map<String, dynamic>? _translationResult;
  bool _isLoading = false;
  bool _isListening = false;
  String? _errorMessage;

  Future<void> _speakText(String text) async {
    if (_ttsService.isPlaying) {
      await _ttsService.stop();
      _ttsPlaying.value = false;
      return;
    }
    _ttsPlaying.value = true;
    _ttsService.onPlaybackStateChanged = () {
      _ttsPlaying.value = _ttsService.isPlaying;
    };
    await _ttsService.play(
      text: text,
      voiceId: 'de-DE-ElkeNeural',
      rateValue: 1.0,
    );
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      final text = await _sttService.stopAndTranscribe();
      if (!mounted) return;
      setState(() {
        _isListening = false;
        if (text.trim().isNotEmpty) {
          _textController.text = text;
        }
      });
    } else {
      setState(() {
        _isListening = true;
      });
      final ok = await _sttService.startRecording();
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _isListening = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _ttsService.dispose();
    _sttService.dispose();
    _ttsPlaying.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _translationResult = null;
    });

    try {
      final result = await AIService.translateWithMeanings(text: text);
      if (!mounted) return;
      setState(() {
        _translationResult = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveWord() async {
    if (_translationResult == null) return;
    
    final meaningsRaw = _translationResult!['meanings'] as List<dynamic>? ?? [];
    final meanings = meaningsRaw.map((e) {
      final map = e as Map<String, dynamic>;
      return WordMeaning(
        translation: map['translation']?.toString() ?? '',
        exampleGerman: map['exampleGerman']?.toString() ?? '',
        exampleUzbek: map['exampleUzbek']?.toString() ?? '',
      );
    }).toList();

    final word = SavedWord(
      germanWord: _translationResult!['original']?.toString() ?? '',
      meanings: meanings,
      savedAt: DateTime.now(),
      learningStage: 0,
    );

    await VocabularyService.addWord(word);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).wordAdded),
          backgroundColor: AppColors.duoGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text(
          l.translationTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.duoTextDark),
      ),
      body: DecorativePatternBackground(
        isDark: isDark,
        variant: DecorativePatternVariant.derDieDas,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            children: [
              // Input section
              GamifiedCard(
                color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.enterGermanWord,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white54 : AppColors.duoTextLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                      ),
                      decoration: InputDecoration(
                        hintText: l.translationHint,
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white38 : AppColors.duoTextLight,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? AppColors.duoRed : AppColors.duoBlue,
                          ),
                          onPressed: _toggleListening,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.duoCardGray.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: GamifiedCard(
                        color: AppColors.duoBlue,
                        shadowColor: AppColors.duoBlueShadow,
                        shadowDepth: 4,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        onTap: _isLoading ? null : _translate,
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  l.translateButton,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Error message
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.duoRed.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.duoRed, width: 2),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.duoRed,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Translation result
              Expanded(
                child: _translationResult == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '📖',
                              style: TextStyle(fontSize: 64, color: isDark ? Colors.white38 : AppColors.duoTextLight),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l.enterWordToTranslate,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white54 : AppColors.duoTextLight,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Original word
                            GamifiedCard(
                              color: AppColors.duoBlue,
                              shadowColor: AppColors.duoBlueShadow,
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l.originalWord,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white.withValues(alpha: 0.8),
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _translationResult!['original'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // TTS tugmasi — nemischa so'zni eshittirish
                                  ValueListenableBuilder<bool>(
                                    valueListenable: _ttsPlaying,
                                    builder: (context, playing, _) {
                                      return IconButton(
                                        icon: Icon(
                                          playing
                                              ? Icons.stop_circle_rounded
                                              : Icons.volume_up_rounded,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        onPressed: () => _speakText(
                                            _translationResult!['original']?.toString() ?? ''),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.bookmark_add_rounded, color: Colors.white, size: 32),
                                    onPressed: _saveWord,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Meanings
                            Text(
                              l.meanings,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.duoTextDark,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),

                            ...(_translationResult!['meanings'] as List<dynamic>? ?? []).asMap().entries.map((entry) {
                              final i = entry.key;
                              final meaning = entry.value as Map<String, dynamic>;
                              return Column(
                                children: [
                                  _buildMeaningCard(meaning, isDark, i + 1),
                                  if (i < (_translationResult!['meanings'] as List<dynamic>).length - 1) const SizedBox(height: 12),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeaningCard(Map<String, dynamic> meaning, bool isDark, int index) {
    final l = AppLocalizations.of(context);
    final translation = meaning['translation'] ?? '';
    final exampleGerman = meaning['exampleGerman'] ?? '';
    final exampleUzbek = meaning['exampleUzbek'] ?? '';

    return GamifiedCard(
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Index and translation
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.duoGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  translation,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
              ),
            ],
          ),
          
          // Example if available
          if (exampleGerman.isNotEmpty && exampleUzbek.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.duoOrange.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.duoOrange.withValues(alpha: 0.3), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        l.example,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.duoOrange,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      // Misol gapni eshittirish tugmasi
                      ValueListenableBuilder<bool>(
                        valueListenable: _ttsPlaying,
                        builder: (context, playing, _) {
                          final isThisPlaying =
                              playing && _ttsService.currentText == exampleGerman;
                          return GestureDetector(
                            onTap: () => _speakText(exampleGerman),
                            child: Icon(
                              isThisPlaying
                                  ? Icons.stop_circle_rounded
                                  : Icons.volume_up_rounded,
                              color: AppColors.duoOrange,
                              size: 22,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exampleGerman,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exampleUzbek,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.duoTextLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
