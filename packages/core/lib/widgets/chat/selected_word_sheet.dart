import 'package:flutter/material.dart';
import '../../services/ai_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/chat_theme.dart';
import '../gamified_card.dart';
import '../../services/vocabulary_service.dart';

class SelectedWordSheet extends StatefulWidget {
  final String word;

  const SelectedWordSheet({super.key, required this.word});

  @override
  State<SelectedWordSheet> createState() => _SelectedWordSheetState();
}

class _SelectedWordSheetState extends State<SelectedWordSheet> {
  String? _explanation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final text = await AIService.explainWord(word: widget.word);
      if (mounted) {
        setState(() {
          _explanation = text;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _explanation = 'Ma\'lumot yuklanmadi: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveWord() async {
    if (_explanation == null) return;
    final wordObj = SavedWord(
      germanWord: widget.word,
      meanings: [
        WordMeaning(
          translation: _explanation!,
          exampleGerman: '',
          exampleUzbek: '',
        )
      ],
      savedAt: DateTime.now(),
      learningStage: 0,
    );

    await VocabularyService.addWord(wordObj);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("So'z saqlandi!"),
          backgroundColor: AppColors.duoGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChatTheme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border, width: 1.5),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.word,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
                if (!_loading)
                  IconButton(
                    icon: const Icon(Icons.bookmark_add_rounded, color: AppColors.duoGreen, size: 32),
                    onPressed: _saveWord,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: AppColors.duoBlue),
                ),
              )
            else
              Text(
                _explanation ?? '',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GamifiedCard(
                color: AppColors.duoBlue,
                shadowColor: AppColors.duoBlueShadow,
                shadowDepth: 4,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onTap: () => Navigator.pop(context),
                child: const Center(
                  child: Text(
                    'Yopish',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
