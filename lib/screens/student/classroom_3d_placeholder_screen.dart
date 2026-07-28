import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/gamified_button.dart';

enum ClassroomCameraMode {
  firstPerson, // O'quvchi ko'zi (Desk view)
  board,       // Doska kamerasi
  teacher,     // O'qituvchi bilan yuzma-yuz / Yuz ko'rinishi
  overview,    // Keng qamrovli 3D xona / Gavda ko'rinishi
  freeOrbit,   // Erkin 360°
}

enum ClassroomViewType {
  classroom,    // 3D Sinfxona
  businesswoman // 3D Businesswoman Personaj
}

enum CharacterEmotion {
  happy,       // Tabassum / Xursand 😃
  explain,     // Mavzu tushuntirish 🧑‍🏫
  speak,       // Gapirish 🗣️
  think,       // O'ylash 🧐
  greet,       // Salomlashish 🖐️
  applaud,     // Rahmat / Ofarin 👏
}

class Classroom3DPlaceholderScreen extends StatefulWidget {
  const Classroom3DPlaceholderScreen({super.key});

  @override
  State<Classroom3DPlaceholderScreen> createState() => _Classroom3DPlaceholderScreenState();
}

class _Classroom3DPlaceholderScreenState extends State<Classroom3DPlaceholderScreen> {
  final Flutter3DController _threeDController = Flutter3DController();
  ClassroomCameraMode _currentCameraMode = ClassroomCameraMode.firstPerson;
  CharacterEmotion _currentEmotion = CharacterEmotion.happy;
  
  bool _hasRaisedHand = false;
  bool _isMicOn = false;
  bool _isModelLoaded = false;
  String _teacherStatus = '3D Sinfxona yuklanmoqda... ⏳';

  @override
  void initState() {
    super.initState();
    // Switch orientation to Landscape & Immersive full screen mode safely on mobile devices
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _enableLandscapeMode();
        }
      });
    }

    // Listen to model load status to update UI
    _threeDController.onModelLoaded.addListener(_onModelLoadedListener);

    // Fallback timeout to ensure screen is unlocked even if web 3d listener lags
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isModelLoaded) {
        setState(() {
          _isModelLoaded = true;
          _teacherStatus = '3D Sinfxona va AI Businesswoman Ustoz tayyor 👩‍💼';
        });
      }
    });
  }

  void _enableLandscapeMode() {
    if (kIsWeb) return; // SystemChrome calls on Web trigger MouseTracker assertion errors
    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (_) {}
  }

  void _restorePortraitMode() {
    if (kIsWeb) return;
    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (_) {}
  }

  @override
  void dispose() {
    _threeDController.onModelLoaded.removeListener(_onModelLoadedListener);
    _restorePortraitMode();
    super.dispose();
  }

  void _onModelLoadedListener() {
    if (_threeDController.onModelLoaded.value && mounted) {
      setState(() {
        _isModelLoaded = true;
        _teacherStatus = 'Dars o\'tmoqda (AI Businesswoman Ustoz bilan muloqot) 👩‍💼';
      });
      _setCameraMode(ClassroomCameraMode.firstPerson);
    }
  }

  void _setCameraMode(ClassroomCameraMode mode) {
    setState(() {
      _currentCameraMode = mode;
    });

    try {
      switch (mode) {
        case ClassroomCameraMode.firstPerson:
          _threeDController.setCameraOrbit(0, 75, 4.5);
          _teacherStatus = 'O\'quvchi ko\'rinishi (Partada o\'tirish) 👁️';
          break;
        case ClassroomCameraMode.board:
          _threeDController.setCameraOrbit(0, 85, 2.5);
          _teacherStatus = 'Doskaga yaqinlashish (Grammatika & Slaydlar) 📋';
          break;
        case ClassroomCameraMode.teacher:
          _threeDController.setCameraOrbit(-15, 80, 2.2);
          _teacherStatus = 'AI Businesswoman Ustoz bilan muloqot 👩‍💼';
          break;
        case ClassroomCameraMode.overview:
          _threeDController.setCameraOrbit(35, 60, 9.0);
          _teacherStatus = '3D Sinfxona umumiy ko\'rinishi 🌐';
          break;
        case ClassroomCameraMode.freeOrbit:
          _threeDController.setCameraOrbit(0, 75, 5.0);
          _teacherStatus = 'Erkin 360° kamera rejimi 🔄';
          break;
      }
    } catch (_) {}
  }

  void _triggerEmotion(CharacterEmotion emotion) {
    setState(() {
      _currentEmotion = emotion;
    });

    String message = '';
    switch (emotion) {
      case CharacterEmotion.happy:
        message = 'AI Businesswoman sizga xursand bo\'lib tabassum qilmoqda! 😃';
        break;
      case CharacterEmotion.explain:
        message = 'AI Businesswoman nemis tili qoidasini tushuntirmoqda! 🧑‍🏫';
        break;
      case CharacterEmotion.speak:
        message = 'AI Businesswoman jonli nutq so\'zlamoqda... 🗣️';
        break;
      case CharacterEmotion.think:
        message = 'AI Businesswoman savolingiz ustida o\'ylanmoqda... 🧐';
        break;
      case CharacterEmotion.greet:
        message = 'AI Businesswoman: "Guten Tag! Willkommen!" 🖐️';
        break;
      case CharacterEmotion.applaud:
        message = 'AI Businesswoman: "Sehr gut! Ofarin!" 👏';
        break;
    }

    setState(() {
      _teacherStatus = message;
    });

    // Try animation trigger on controller if present
    try {
      _threeDController.playAnimation();
    } catch (_) {}
  }

  void _toggleHandRaise() {
    setState(() {
      _hasRaisedHand = !_hasRaisedHand;
      if (_hasRaisedHand) {
        _teacherStatus = 'Siz qo\'l ko\'tardingiz 🖐️ (AI Ustoz e\'tibor qaratmoqda)';
        _triggerEmotion(CharacterEmotion.explain);
      } else {
        _teacherStatus = 'Dars o\'tmoqda (AI Ustoz bilan faol muloqot) 🧑‍🏫';
      }
    });
  }

  void _toggleMic() {
    setState(() {
      _isMicOn = !_isMicOn;
      if (_isMicOn) {
        _triggerEmotion(CharacterEmotion.speak);
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _isMicOn ? AppColors.duoGreen : AppColors.duoOrange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            Icon(_isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isMicOn
                    ? 'Mikrofon yoqildi. AI Ustoz bilan gaplashishingiz mumkin!'
                    : 'Mikrofon o\'chirildi.',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exitClassroom() {
    _restorePortraitMode();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    const modelSrc = 'assets/3D-fayl/classroom.glb';

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _restorePortraitMode();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F171A) : const Color(0xFF131F24),
        body: SafeArea(
          child: Stack(
            children: [
              // 1. Fullscreen 3D Scene Viewport (Textured 3D Classroom with Businesswoman Teacher)
              Positioned.fill(
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: Flutter3DViewer(
                    activeGestureInterceptor: true,
                    progressBarColor: AppColors.duoGreen,
                    controller: _threeDController,
                    src: modelSrc,
                  ),
                ),
              ),

              // Styled 3D Classroom Loading Overlay (fades out as soon as 3D WebGL model is loaded)
              AnimatedOpacity(
                opacity: _isModelLoaded ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 600),
                child: _isModelLoaded
                    ? const SizedBox.shrink()
                    : Positioned.fill(
                        child: IgnorePointer(
                          ignoring: true,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.2,
                                colors: [
                                  Color(0xFF1E2D34),
                                  Color(0xFF0F171A),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(color: AppColors.duoGreen),
                                  const SizedBox(height: 20),
                                  Text(
                                    _teacherStatus,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
              ),

              // 2. Top Game HUD Bar (Navigation & Camera Controls)
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button & Room Title Badge
                    Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _exitClassroom,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2C33),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white38, width: 1.5),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Chiqish',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Title Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.duoGreen.withValues(alpha: 0.6), width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.duoGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '3D SINFXONA & AI USTOZ 👩‍💼',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Top Right Controls (Camera Mode Selector Dock)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCameraChip(
                            mode: ClassroomCameraMode.firstPerson,
                            label: '👁️ O\'quvchi',
                          ),
                          const SizedBox(width: 4),
                          _buildCameraChip(
                            mode: ClassroomCameraMode.board,
                            label: '📋 Doska',
                          ),
                          const SizedBox(width: 4),
                          _buildCameraChip(
                            mode: ClassroomCameraMode.teacher,
                            label: '👩‍💼 AI Ustoz',
                          ),
                          const SizedBox(width: 4),
                          _buildCameraChip(
                            mode: ClassroomCameraMode.overview,
                            label: '🌐 Xona',
                          ),
                          const SizedBox(width: 4),
                          _buildCameraChip(
                            mode: ClassroomCameraMode.freeOrbit,
                            label: '🔄 Erkin',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Bottom Game Action Controls, Emotion Bar & Status Dock
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Emotion Selector Bar (Active for 3D Businesswoman Teacher)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF142127).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.starYellow.withValues(alpha: 0.7), width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildEmotionChip(CharacterEmotion.happy, '😃 Tabassum'),
                            const SizedBox(width: 6),
                            _buildEmotionChip(CharacterEmotion.explain, '🧑‍🏫 Tushuntirish'),
                            const SizedBox(width: 6),
                            _buildEmotionChip(CharacterEmotion.speak, '🗣️ Gapirish'),
                            const SizedBox(width: 6),
                            _buildEmotionChip(CharacterEmotion.think, '🧐 O\'ylash'),
                            const SizedBox(width: 6),
                            _buildEmotionChip(CharacterEmotion.greet, '🖐️ Salom'),
                            const SizedBox(width: 6),
                            _buildEmotionChip(CharacterEmotion.applaud, '👏 Ofarin'),
                          ],
                        ),
                      ),
                    ),

                    // Status Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF19272E),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _hasRaisedHand ? AppColors.duoOrange : AppColors.duoBlue,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 4))
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _hasRaisedHand ? Icons.pan_tool_rounded : Icons.auto_awesome_rounded,
                            size: 20,
                            color: _hasRaisedHand ? AppColors.duoOrange : AppColors.starYellow,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _teacherStatus,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Action Buttons Dock
                    Row(
                      children: [
                        // Raise Hand Button
                        Expanded(
                          child: GamifiedButton(
                            text: _hasRaisedHand ? 'Qo\'lni tushirish 🖐️' : 'Qo\'l ko\'tarish 🖐️',
                            onPressed: _toggleHandRaise,
                            color: _hasRaisedHand ? AppColors.duoOrange : AppColors.duoBlue,
                            shadowColor: _hasRaisedHand ? AppColors.duoOrangeShadow : AppColors.duoBlueShadow,
                            height: 46,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Mic Button
                        Expanded(
                          child: GamifiedButton(
                            text: _isMicOn ? 'Mikrofon: YOQILGAN 🎙️' : 'Gapirish 🎙️',
                            onPressed: _toggleMic,
                            color: _isMicOn ? AppColors.duoGreen : const Color(0xFF2C3E50),
                            shadowColor: _isMicOn ? AppColors.duoGreenShadow : const Color(0xFF1A252F),
                            height: 46,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Class Materials Button
                        GamifiedButton(
                          text: '📋 Materiallar',
                          onPressed: () {
                            _showClassMaterialsDialog(context);
                          },
                          color: AppColors.duoPurple,
                          shadowColor: AppColors.duoPurpleShadow,
                          height: 46,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionChip(CharacterEmotion emotion, String label) {
    final isSelected = _currentEmotion == emotion;
    return InkWell(
      onTap: () => _triggerEmotion(emotion),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.starYellow : Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.starYellow : Colors.white24,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCameraChip({
    required ClassroomCameraMode mode,
    required String label,
  }) {
    final isSelected = _currentCameraMode == mode;
    return InkWell(
      onTap: () => _setCameraMode(mode),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.duoBlue : Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.duoBlue : Colors.white24,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.duoBlue.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _showClassMaterialsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF19272E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.school_rounded, color: AppColors.duoPurple),
              SizedBox(width: 10),
              Text(
                'DARS MATERIALLARI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMaterialItem(Icons.picture_as_pdf_rounded, '3D Businesswoman & Xona Qo\'llanmasi', 'PDF fayl (1.2 MB)'),
              const SizedBox(height: 10),
              _buildMaterialItem(Icons.headset_rounded, 'Nemis tili muloqot va talaffuz mashqlari', 'Audio fayllar'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'YOPISH',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMaterialItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.duoPurple, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

