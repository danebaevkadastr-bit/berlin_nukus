import 'package:flutter/material.dart';
import 'package:core/l10n/locale_manager.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/widgets/gamified_card.dart';
import 'package:core/models/video_models.dart';
import 'package:core/repositories/video_repository.dart';
import 'video_player_screen.dart';

class VideoCatalogScreen extends StatefulWidget {
  const VideoCatalogScreen({super.key});

  @override
  State<VideoCatalogScreen> createState() => _VideoCatalogScreenState();
}

class _VideoCatalogScreenState extends State<VideoCatalogScreen> {
  final VideoRepository _videoRepository = VideoRepository();
  Future<List<GermanVideo>>? _videosFuture;

  String _selectedLevel = 'All';
  String _selectedCategory = 'All';

  final List<String> _levels = ['All', 'A1', 'A2', 'B1'];
  final List<String> _categories = ['All', 'Nicos Weg', 'Easy German'];

  @override
  void initState() {
    super.initState();
    _videosFuture = _videoRepository.getVideos();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final langCode = LocaleManager.code;

    return FutureBuilder<List<GermanVideo>>(
      future: _videosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
            appBar: AppBar(title: const Text('...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
            appBar: AppBar(),
            body: Center(child: Text('Xatolik: ${snapshot.error}')),
          );
        }

        final videos = snapshot.data ?? [];
        final filteredVideos = videos.where((v) {
          final matchesCategory = _selectedCategory == 'Barchasi' || v.category == _selectedCategory;
          final matchesLevel = _selectedLevel == 'Barchasi' || v.level == _selectedLevel;
          return matchesCategory && matchesLevel;
        }).toList();

        return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : AppColors.duoTextDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          langCode == 'kaa' ? 'Video-Sabaqlar 🎬' : (langCode == 'ru' ? 'Видео-Уроки 🎬' : 'Video-Darslar 🎬'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle intro banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.duoBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.duoBlue.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.subtitles_rounded, color: AppColors.duoBlue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      langCode == 'kaa'
                          ? 'Subtitrdegi sózlerdi basıp, tilińizge awdarmasınıń hám sózlikke saqlań!'
                          : (langCode == 'ru'
                              ? 'Нажимайте на слова в субтитрах, чтобы перевести и сохранить их!'
                              : 'Subtitrdagi so\'zlarni bosib, o\'zingizga tarjimasini ko\'ring va lug\'atga saqlang!'),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.duoBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Kategoriya va Daraja filterlari
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1-Qator: Kategoriya
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((c) {
                      final isSelected = _selectedCategory == c;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            c == 'All' ? 'Barchasi' : c,
                            style: TextStyle(
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.duoTextDark),
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.duoGreen,
                          backgroundColor: isDark ? const Color(0xFF1F2C33) : Colors.white,
                          checkmarkColor: Colors.white,
                          onSelected: (sel) {
                            if (sel) setState(() => _selectedCategory = c);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 4),

                // 2-Qator: Darajalar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _levels.map((l) {
                      final isSelected = _selectedLevel == l;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            l == 'All' ? 'Barcha darajalar' : 'Daraja $l',
                            style: TextStyle(
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.duoTextDark),
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.duoOrange,
                          backgroundColor: isDark ? const Color(0xFF1F2C33) : Colors.white,
                          checkmarkColor: Colors.white,
                          onSelected: (sel) {
                            if (sel) setState(() => _selectedLevel = l);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Videos List
          Expanded(
            child: filteredVideos.isEmpty
                ? Center(
                    child: Text(
                      'Videolar topilmadi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white54 : AppColors.duoTextLight,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                    itemCount: filteredVideos.length,
                    itemBuilder: (context, i) {
                      final video = filteredVideos[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GamifiedCard(
                          color: isDark ? const Color(0xFF1F2C33) : Colors.white,
                          shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                          shadowDepth: 3,
                          padding: const EdgeInsets.all(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoPlayerScreen(video: video),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              // Video Thumbnail Stack
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: AppColors.duoBlue.withValues(alpha: 0.2),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        'https://img.youtube.com/vi/${video.youtubeId}/mqdefault.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Center(
                                          child: Icon(Icons.play_circle_fill_rounded,
                                              size: 36, color: AppColors.duoBlue),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.black45,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                                  ),
                                  Positioned(
                                    right: 4,
                                    bottom: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        video.durationText,
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),

                              // Info Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: video.level == 'A1'
                                                ? AppColors.duoGreen.withValues(alpha: 0.15)
                                                : (video.level == 'A2'
                                                    ? AppColors.duoBlue.withValues(alpha: 0.15)
                                                    : AppColors.duoOrange.withValues(alpha: 0.15)),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            video.level,
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w900,
                                              color: video.level == 'A1'
                                                  ? AppColors.duoGreen
                                                  : (video.level == 'A2'
                                                      ? AppColors.duoBlue
                                                      : AppColors.duoOrange),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          video.category,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? Colors.white60 : AppColors.duoTextLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      video.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : AppColors.duoTextDark,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      video.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white60 : AppColors.duoTextLight,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
        );
      },
    );
  }
}
