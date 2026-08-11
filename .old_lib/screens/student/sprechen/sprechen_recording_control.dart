import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/locale_manager.dart';
import '../../../services/audio_recorder_service.dart';
import '../../../services/sprechen_evaluation_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/theme_manager.dart';
import 'sprechen_data.dart';
import 'sprechen_recording_models.dart';

/// Bir vaqtda faqat bitta yozish bo'lishini ta'minlovchi koordinator.
/// Yangi yozish boshlanganda oldingisi to'xtatiladi.
class SprechenRecordingCoordinator {
  final ValueNotifier<AufgabeKey?> active = ValueNotifier<AufgabeKey?>(null);

  void setActive(AufgabeKey key) => active.value = key;
  void clear(AufgabeKey key) {
    if (active.value == key) active.value = null;
  }

  void dispose() => active.dispose();
}

/// Har Aufgabe uchun audio yozish, tinglash va AI baholash kontroli.
class SprechenRecordingControl extends StatefulWidget {
  final AufgabeKey aufgabeKey;
  final SprechenAufgabe aufgabe;
  final String level;
  final SprechenRecordingCoordinator coordinator;

  /// Optional callback invoked with the AI [AudioEvaluation] once an evaluation
  /// completes successfully. Lets a host (e.g. the B1 mock test) capture the
  /// result without changing the control's self-contained UX. `null` by default
  /// so existing usages are unaffected.
  final void Function(AudioEvaluation evaluation)? onEvaluated;

  /// Imtihon rejimi: `true` bo'lganda AI bahosi (feedback paneli va ball)
  /// ko'rsatilmaydi — javob yuborilgach faqat "qabul qilindi" tasdig'i
  /// chiqadi. Baho keyinroq (mock test natija ekranida) ko'rinadi. Sprechen
  /// mashq bo'limida `false` (baho darhol ko'rinadi).
  final bool hideFeedback;

  /// Berilgan bo'lsa, "yuborish" AI baholashni DARHOL ishlatmaydi — audio
  /// baytlarini shu callbackga beradi (mock test uni saqlab, test yakunida
  /// baholaydi). Shunda o'quvchi baholashni kutmaydi. null bo'lsa oddiy rejim.
  final Future<void> Function(Uint8List bytes, String mimeType)? onAudioSubmit;

  /// AI baholash (network) boshlanganда chaqiriladi. Mock test buni pending
  /// hisoblagichni oshirish uchun ishlatadi.
  final VoidCallback? onEvaluationStart;

  /// AI baholash tugaганда (muvaffaqiyat yoki xato — har doim) chaqiriladi.
  final VoidCallback? onEvaluationEnd;

  const SprechenRecordingControl({
    super.key,
    required this.aufgabeKey,
    required this.aufgabe,
    required this.level,
    required this.coordinator,
    this.onEvaluated,
    this.hideFeedback = false,
    this.onEvaluationStart,
    this.onEvaluationEnd,
    this.onAudioSubmit,
  });

  @override
  State<SprechenRecordingControl> createState() =>
      _SprechenRecordingControlState();
}

class _SprechenRecordingControlState extends State<SprechenRecordingControl> {
  final AudioRecorderService _recorder = AudioRecorderService.instance;
  final AudioPlayer _player = AudioPlayer();

  SprechenRecordingState _state = const SprechenRecordingState();
  StreamSubscription<int>? _elapsedSub;
  StreamSubscription<PlayerState>? _playerSub;
  bool _isPlaying = false;
  bool _showFeedback = true;

  Color get _accent => ThemeManager.accent;

  @override
  void initState() {
    super.initState();
    widget.coordinator.active.addListener(_onActiveChanged);
    _playerSub = _player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => _isPlaying = s == PlayerState.playing);
    });
  }

  void _onActiveChanged() {
    // Boshqa Aufgabe yozishni boshlasa va biz yozayotgan bo'lsak — to'xtatamiz.
    final active = widget.coordinator.active.value;
    if (active != null &&
        active != widget.aufgabeKey &&
        _state.phase == RecordingPhase.recording) {
      _stopRecording(auto: false);
      // Foydalanuvchiga qisqa xabar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Yozuv boshqa topshiriq ochilgani uchun to\'xtatildi.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    widget.coordinator.active.removeListener(_onActiveChanged);
    _elapsedSub?.cancel();
    _playerSub?.cancel();
    _player.dispose();
    // Yozilgan vaqtinchalik faylni o'chiramiz (saqlash yo'q).
    final path = _state.filePathOrBlobUrl;
    if (path != null && path.isNotEmpty) {
      _recorder.deleteRecording(path);
    }
    super.dispose();
  }

  // ── Yozish ───────────────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    if (!AudioRecorderService.isSupportedPlatform) {
      _setError(const SprechenError(SprechenErrorType.unsupportedPlatform));
      return;
    }

    // Ruxsat tekshiruvi
    final has = await _recorder.hasPermission();
    if (!has) {
      final result = await _recorder.requestPermission();
      if (result == MicPermissionResult.permanentlyDenied) {
        _setError(const SprechenError(SprechenErrorType.micPermanentlyDenied));
        return;
      }
      if (result != MicPermissionResult.granted) {
        _setError(const SprechenError(SprechenErrorType.micDenied));
        return;
      }
    }

    // Avvalgi yozuvni tozalaymiz
    await _player.stop();
    final old = _state.filePathOrBlobUrl;
    if (old != null && old.isNotEmpty) {
      await _recorder.deleteRecording(old);
    }

    widget.coordinator.setActive(widget.aufgabeKey);

    try {
      await _recorder.start(
        recordingName: 'sprechen_${widget.aufgabeKey.hashCode}',
        onAutoStop: (audio) => _onRecordingDone(audio, auto: true),
      );
    } catch (e) {
      widget.coordinator.clear(widget.aufgabeKey);
      debugPrint('Sprechen recording start failed: $e');
      _setError(SprechenError(SprechenErrorType.recordStartFailed, e.toString()));
      return;
    }

    _elapsedSub?.cancel();
    _elapsedSub = _recorder.elapsed.listen((sec) {
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(
          phase: RecordingPhase.recording,
          elapsedSeconds: sec,
        );
      });
    });

    if (!mounted) return;
    setState(() {
      _state = const SprechenRecordingState(
        phase: RecordingPhase.recording,
        elapsedSeconds: 0,
      );
    });
  }

  Future<void> _stopRecording({required bool auto}) async {
    try {
      final audio = await _recorder.stop();
      if (audio != null) {
        _onRecordingDone(audio, auto: auto);
      }
    } catch (e) {
      _setError(SprechenError(SprechenErrorType.recordingFailed, e.toString()));
    }
  }

  void _onRecordingDone(RecordedAudio audio, {required bool auto}) {
    _elapsedSub?.cancel();
    widget.coordinator.clear(widget.aufgabeKey);
    if (!mounted) return;
    setState(() {
      _state = _state.copyWith(
        phase: RecordingPhase.recorded,
        filePathOrBlobUrl: audio.pathOrBlobUrl,
        mimeType: audio.mimeType,
        reachedMaxLength: audio.reachedMaxLength,
        clearError: true,
      );
    });
    if (audio.reachedMaxLength && mounted) {
      final l = AppLocalizations.of(context);
      _snack(l.sprechenMaxLengthReached, AppColors.duoOrange);
    }
  }

  // ── Tinglash ───────────────────────────────────────────────────────────────
  Future<void> _togglePlay() async {
    final path = _state.filePathOrBlobUrl;
    if (path == null || path.isEmpty) return;
    if (_isPlaying) {
      await _player.pause();
      return;
    }
    try {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
    } catch (_) {
      // web yoki boshqa holatda UrlSource
      try {
        await _player.play(UrlSource(path));
      } catch (_) {}
    }
  }

  // ── Yuborish ───────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_state.isBusy) return; // ikkilamchi submit'ni bloklash
    final path = _state.filePathOrBlobUrl;
    final mime = _state.mimeType;
    if (path == null || path.isEmpty || mime == null) return;

    await _player.stop();

    setState(() {
      _state = _state.copyWith(
        phase: RecordingPhase.uploading,
        clearError: true,
        clearFeedback: true,
      );
    });

    // Mock test pending hisoblagichini oshirish (test yakunlashдан oldin
    // kutilishi uchun). Har holda (muvaffaqiyat/xato) finally'да tushiriladi.
    widget.onEvaluationStart?.call();
    try {
      final bytes = await _recorder.readBytes(path);

      // Mock test rejimi: baholashni KUTMAYMIZ — audioni hostga (controllerга)
      // saqlab qo'yamiz, baholash test yakunida bajariladi.
      if (widget.onAudioSubmit != null) {
        await widget.onAudioSubmit!(bytes, mime);
        if (!mounted) return;
        setState(() {
          _state = _state.copyWith(phase: RecordingPhase.done);
        });
        return;
      }

      if (mounted) {
        setState(() {
          _state = _state.copyWith(phase: RecordingPhase.evaluating);
        });
      }

      final lang = LocaleManager.code;
      final evaluation = await SprechenEvaluationService.evaluate(
        audioBytes: bytes,
        mimeType: mime,
        aufgabe: widget.aufgabe,
        level: widget.level,
        uiLangCode: lang,
      );

      // Bahoni AVVAL controllerga yozamiz — widget dispose bo'lgan (boshqa
      // Teilga o'tilgan) bo'lsa ham baho yo'qolmasin.
      widget.onEvaluated?.call(evaluation);

      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(
          phase: RecordingPhase.done,
          feedback: evaluation,
        );
        _showFeedback = true;
      });
    } on SprechenError catch (e) {
      _setError(e);
    } catch (e) {
      _setError(SprechenError(SprechenErrorType.evaluationFailed, e.toString()));
    } finally {
      widget.onEvaluationEnd?.call();
    }
  }

  void _setError(SprechenError error) {
    if (!mounted) return;
    // Yozuv saqlanadi (agar bor bo'lsa) — qayta yuborish uchun.
    setState(() {
      _state = _state.copyWith(phase: RecordingPhase.error, error: error);
    });
    final l = AppLocalizations.of(context);
    _snack(_errorMessage(l, error), AppColors.duoRed);
  }

  String _errorMessage(AppLocalizations l, SprechenError e) {
    switch (e.type) {
      case SprechenErrorType.micDenied:
        return l.sprechenMicPermissionDenied;
      case SprechenErrorType.micPermanentlyDenied:
        return l.sprechenMicPermissionSettings;
      case SprechenErrorType.unsupportedPlatform:
        return l.sprechenRecordingUnavailable;
      case SprechenErrorType.uploadFailed:
        return l.sprechenUploadError;
      case SprechenErrorType.timeout:
        return l.sprechenTimeoutError;
      case SprechenErrorType.recordStartFailed:
      case SprechenErrorType.recordingFailed:
        return l.sprechenRecordingError;
      case SprechenErrorType.evaluationFailed:
      case SprechenErrorType.parseError:
        return l.sprechenEvaluationError;
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _fmt(int sec) {
    final m = (sec ~/ 60).toString();
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    if (!AudioRecorderService.isSupportedPlatform) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Text(
          l.sprechenRecordingUnavailable,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.duoRed,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildControlRow(l, isDark),
          // Imtihon rejimida (hideFeedback) baho ko'rsatilmaydi.
          if (!widget.hideFeedback &&
              _state.phase == RecordingPhase.done &&
              _state.feedback != null)
            _buildFeedbackPanel(l, isDark, _state.feedback!),
        ],
      ),
    );
  }

  Widget _buildControlRow(AppLocalizations l, bool isDark) {
    final phase = _state.phase;

    // Yozish ketyapti
    if (phase == RecordingPhase.recording) {
      final remaining =
          AudioRecorderService.maxDurationSeconds - _state.elapsedSeconds;
      return Row(
        children: [
          _circleButton(
            icon: Icons.stop_rounded,
            color: AppColors.duoRed,
            onTap: () => _stopRecording(auto: false),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _PulsingDot(),
                    const SizedBox(width: 6),
                    Text(
                      l.sprechenRecordingStatus,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.duoRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmt(_state.elapsedSeconds)}  •  −${_fmt(remaining)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Yuborilyapti / baholanyapti
    if (phase == RecordingPhase.uploading ||
        phase == RecordingPhase.evaluating) {
      return Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: _accent),
          ),
          const SizedBox(width: 12),
          Text(
            l.sprechenEvaluating,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _accent,
            ),
          ),
        ],
      );
    }

    // Imtihon rejimi: yuborilgach baho ko'rsatilmaydi — faqat tasdiq va
    // (xohlasa) qayta yozish imkoni.
    if (widget.hideFeedback && phase == RecordingPhase.done) {
      return Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.duoGreen, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l.sprechenMockSubmitted,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: isDark ? Colors.white : AppColors.duoTextDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _pillButton(
            icon: Icons.mic_rounded,
            label: l.sprechenReRecord,
            color: AppColors.duoOrange,
            onTap: _startRecording,
          ),
        ],
      );
    }

    // Yozildi / xato / tugadi — tinglash + qayta yozish + yuborish
    if (_state.hasRecording) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _pillButton(
            icon: _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            label: _isPlaying ? l.sprechenPause : l.sprechenPlay,
            color: _accent,
            onTap: _togglePlay,
          ),
          _pillButton(
            icon: Icons.mic_rounded,
            label: l.sprechenReRecord,
            color: AppColors.duoOrange,
            onTap: _startRecording,
          ),
          _pillButton(
            icon: phase == RecordingPhase.error
                ? Icons.refresh_rounded
                : Icons.send_rounded,
            label: phase == RecordingPhase.error
                ? l.sprechenRetry
                : l.sprechenSubmit,
            color: AppColors.duoGreen,
            onTap: _submit,
            filled: true,
          ),
        ],
      );
    }

    // Boshlang'ich (idle) yoki ruxsat xatosi — yozish tugmasi
    return Row(
      children: [
        _circleButton(
          icon: Icons.mic_rounded,
          color: _accent,
          onTap: _startRecording,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            l.sprechenRecord,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
        ),
        if (phase == RecordingPhase.error &&
            _state.error?.type == SprechenErrorType.micPermanentlyDenied)
          TextButton(
            onPressed: _recorder.openSettings,
            child: Text(l.sprechenOpenSettings),
          ),
      ],
    );
  }

  Widget _buildFeedbackPanel(
      AppLocalizations l, bool isDark, AudioEvaluation fb) {
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.duoGreen.withValues(alpha: isDark ? 0.1 : 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.duoGreen.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _showFeedback = !_showFeedback),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.grading_rounded,
                        size: 18, color: AppColors.duoGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${l.sprechenFeedbackTitle}  •  ${l.sprechenScore}: ${fb.score}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.duoGreen,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _showFeedback ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.duoGreen),
                    ),
                  ],
                ),
              ),
            ),
            if (_showFeedback)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fbRow(l.sprechenPronunciation, fb.pronunciation, textPrimary),
                    _fbRow(l.sprechenFluency, fb.fluency, textPrimary),
                    _fbRow(l.sprechenGrammar, fb.grammar, textPrimary),
                    _fbRow(l.sprechenContent, fb.content, textPrimary),
                    _fbRow(l.sprechenOverall, fb.overall, textPrimary),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fbRow(String label, String value, Color textColor) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.duoGreen,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6)],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _pillButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: filled ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: filled ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yozish vaqtidagi qizil "yonib turuvchi" nuqta.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_c),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppColors.duoRed,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
