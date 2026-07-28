import re
with open("lib/services/gemini_live_service.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Imports
content = content.replace("import 'package:audioplayers/audioplayers.dart';",
                          "import 'package:audioplayers/audioplayers.dart';\nimport 'package:sound_stream/sound_stream.dart';")

# Variables
old_vars = """  final AudioPlayer _player = AudioPlayer();
  // Aksirish/yo'talish tovush effektlari uchun alohida player.
  final AudioPlayer _sfxPlayer = AudioPlayer();

  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  StreamSubscription<Uint8List>? _micSub;
  StreamSubscription<void>? _playerCompleteSub;

  // Audio chunklarini real-time (oqim) ijro etish uchun navbat:
  final List<Uint8List> _pcmQueue = [];
  bool _isPlayingPcm = false;
  final BytesBuilder _pcmBuffer = BytesBuilder();
  bool _turnCompleteReceived = true;

  // Amplitude tracking uchun: ijro paytida raw PCM saqlash va timer.
  Uint8List? _playingPcm;
  Timer? _ampTimer;"""

new_vars = """  final PlayerStream _playerStream = PlayerStream();
  // Aksirish/yo'talish tovush effektlari uchun alohida player.
  final AudioPlayer _sfxPlayer = AudioPlayer();

  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  StreamSubscription<Uint8List>? _micSub;

  // Audio oqimi holati:
  DateTime? _expectedPlaybackEnd;"""

content = content.replace(old_vars, new_vars)

# Connect initialization
old_conn = """    try {
      // Worker proksi orqali ulanamiz"""
new_conn = """    try {
      await _playerStream.initialize(sampleRate: 24000);
      await _playerStream.start();
      
      // Worker proksi orqali ulanamiz"""
content = content.replace(old_conn, new_conn)

# onMessage processing
old_msg = """        // Model audio qismlarini yig'amiz.
        final modelTurn = serverContent['modelTurn'] as Map<String, dynamic>?;
        if (modelTurn != null) {
          _turnCompleteReceived = false;
          if (!_closed && state.value != AiFaceState.speaking) {
            state.value = AiFaceState.thinking; // Audio yig'ilmoqda
          }
          final parts = modelTurn['parts'] as List<dynamic>? ?? [];
          for (final p in parts) {
            final inline = (p as Map<String, dynamic>)['inlineData']
                as Map<String, dynamic>?;
            if (inline != null && inline['data'] != null) {
              // Real-time oqim uchun audioni navbatga qo'shamiz
              final pcm = base64Decode(inline['data'] as String);
              _pcmBuffer.add(pcm);
              // ~0.5 soniya (24000 bayt) yig'ilganda bitta chunk qilib ijro etamiz
              if (_pcmBuffer.length >= 24000) {
                _pcmQueue.add(_pcmBuffer.takeBytes());
                _playNextPcmChunk();
              }
            }
          }
        }

        // Foydalanuvchi botni to'xtatdi (barge-in).
        if (serverContent['interrupted'] == true) {
          _player.stop();
          _stopAmpTimer();
          _pcmQueue.clear();
          _pcmBuffer.clear();
          _isPlayingPcm = false;
          _turnCompleteReceived = true;
          if (!_closed) state.value = AiFaceState.listening;
        }

        // Navbat tugadi — qolgan audioni ham navbatga qo'shamiz.
        if (serverContent['turnComplete'] == true) {
          _turnCompleteReceived = true;
          if (_pcmBuffer.isNotEmpty) {
            _pcmQueue.add(_pcmBuffer.takeBytes());
            _playNextPcmChunk();
          }
          
          final finalEmotion = _inferEmotion(_turnText.toString());
          _turnText.clear();
          
          // Agar hozir ijro etilmayotgan bo'lsa va navbat bo'sh bo'lsa, tinglash holatiga qaytamiz
          if (!_isPlayingPcm && _pcmQueue.isEmpty) {
            if (!_closed) {
              state.value = AiFaceState.listening;
              emotion.value = AiFaceEmotion.neutral;
              mouthLevel.value = 0.0;
            }
          } else {
            // Emotsiyani yangilash
            emotion.value = finalEmotion;
          }
        }"""

new_msg = """        // Model audio qismlarini yig'amiz.
        final modelTurn = serverContent['modelTurn'] as Map<String, dynamic>?;
        if (modelTurn != null) {
          final parts = modelTurn['parts'] as List<dynamic>? ?? [];
          for (final p in parts) {
            final inline = (p as Map<String, dynamic>)['inlineData']
                as Map<String, dynamic>?;
            if (inline != null && inline['data'] != null) {
              final pcm = base64Decode(inline['data'] as String);
              _feedAudioChunk(pcm);
            }
          }
        }

        // Foydalanuvchi botni to'xtatdi (barge-in).
        if (serverContent['interrupted'] == true) {
          _playerStream.stop();
          _playerStream.initialize(sampleRate: 24000);
          _playerStream.start();
          _expectedPlaybackEnd = null;
          if (!_closed) state.value = AiFaceState.listening;
        }

        // Navbat tugadi.
        if (serverContent['turnComplete'] == true) {
          final finalEmotion = _inferEmotion(_turnText.toString());
          _turnText.clear();
          
          final remaining = _expectedPlaybackEnd?.difference(DateTime.now()) ?? Duration.zero;
          
          void setDone() {
             if (_closed) return;
             if (_expectedPlaybackEnd != null && _expectedPlaybackEnd!.isAfter(DateTime.now())) return;
             state.value = AiFaceState.listening;
             emotion.value = AiFaceEmotion.neutral;
             mouthLevel.value = 0.0;
          }
          
          if (remaining.isNegative) {
            setDone();
          } else {
            emotion.value = finalEmotion;
            Timer(remaining, setDone);
          }
        }"""
content = content.replace(old_msg, new_msg)

# interrupt
old_int = """  void interrupt() {
    if (!_connected || _closed) return;
    _player.stop();
    _stopAmpTimer();
    _pcmQueue.clear();
    _pcmBuffer.clear();
    _isPlayingPcm = false;
    _turnCompleteReceived = true;
    state.value = AiFaceState.listening;
  }"""
new_int = """  void interrupt() {
    if (!_connected || _closed) return;
    _playerStream.stop();
    _playerStream.initialize(sampleRate: 24000);
    _playerStream.start();
    _expectedPlaybackEnd = null;
    state.value = AiFaceState.listening;
  }"""
content = content.replace(old_int, new_int)

# reconnect
old_rec = """      _connected = false;
      _pcmQueue.clear();
      _pcmBuffer.clear();
      _isPlayingPcm = false;
      _turnCompleteReceived = true;
      _micFlushTimer?.cancel();
      _micFlushTimer = null;
      await _micSub?.cancel();
      _micSub = null;
      try {
        await _recorder.stop();
      } catch (_) {}
      await _wsSub?.cancel();
      _wsSub = null;
      _keepAliveTimer?.cancel();
      _keepAliveTimer = null;
      try {
        await _channel?.sink.close();
      } catch (_) {}
      _channel = null;
      try {
        await _player.stop();
      } catch (_) {}"""
new_rec = """      _connected = false;
      _expectedPlaybackEnd = null;
      _micFlushTimer?.cancel();
      _micFlushTimer = null;
      await _micSub?.cancel();
      _micSub = null;
      try {
        await _recorder.stop();
      } catch (_) {}
      await _wsSub?.cancel();
      _wsSub = null;
      _keepAliveTimer?.cancel();
      _keepAliveTimer = null;
      try {
        await _channel?.sink.close();
      } catch (_) {}
      _channel = null;
      try {
        await _playerStream.stop();
      } catch (_) {}"""
content = content.replace(old_rec, new_rec)

# playTurn -> feedChunk
content = re.sub(r'  /// Navbatdagi audio chunkni o\'qiydi \(real-time streaming simulatsiyasi\).*?  void _stopAmpTimer\(\) \{.*?  \}', """  void _feedAudioChunk(Uint8List pcm) {
    if (state.value != AiFaceState.speaking) {
      state.value = AiFaceState.speaking;
    }
    _playerStream.writeChunk(pcm);

    final durationMs = (pcm.length / 48000 * 1000).toInt();
    final now = DateTime.now();
    final startPlayTime = _expectedPlaybackEnd != null && _expectedPlaybackEnd!.isAfter(now)
        ? _expectedPlaybackEnd!
        : now;
    
    _expectedPlaybackEnd = startPlayTime.add(Duration(milliseconds: durationMs));

    double sum = 0;
    int count = 0;
    for (int i = 0; i < pcm.length - 1; i += 2) {
      final sample = (pcm[i] | (pcm[i + 1] << 8)).toSigned(16);
      sum += sample * sample;
      count++;
    }
    final rms = count > 0 ? math.sqrt(sum / count) : 0;
    final level = (rms / 8000.0).clamp(0.0, 1.0);

    final delay = startPlayTime.difference(DateTime.now());
    if (delay.isNegative) {
      if (!_closed) mouthLevel.value = level;
    } else {
      Timer(delay, () {
        if (!_closed) mouthLevel.value = level;
      });
    }
  }""", content, flags=re.DOTALL)


# _pcm16ToWav remove
content = re.sub(r'  /// PCM16 \(mono\) baytlarini ijro etiladigan WAV formatiga o\'raydi\.\n  Uint8List _pcm16ToWav.*?\n    return b\.toBytes\(\);\n  \}', '', content, flags=re.DOTALL)

# disconnect
old_disc = """    _channel = null;
    _pcmQueue.clear();
    _pcmBuffer.clear();
    _isPlayingPcm = false;
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _sfxPlayer.stop();
    } catch (_) {}
  }

  void dispose() {
    disconnect();
    _stopAmpTimer();
    _playerCompleteSub?.cancel();
    _recorder.dispose();
    _player.dispose();"""
new_disc = """    _channel = null;
    _expectedPlaybackEnd = null;
    try {
      await _playerStream.stop();
      _playerStream.dispose();
    } catch (_) {}
    try {
      await _sfxPlayer.stop();
    } catch (_) {}
  }

  void dispose() {
    disconnect();
    _recorder.dispose();"""
content = content.replace(old_disc, new_disc)

with open("lib/services/gemini_live_service.dart", "w", encoding="utf-8") as f:
    f.write(content)
print("done")
