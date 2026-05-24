import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/chat_progress_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/chat_theme.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/gamified_card.dart';
import '../../l10n/app_localizations.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  String selectedLevel = 'A1';
  Set<String> _completedTopics = {};

  final Map<String, IconData> levelIcons = {
    'A1': Icons.menu_book_rounded,
    'A2': Icons.book_rounded,
    'B1': Icons.library_books_rounded,
    'B2': Icons.auto_stories_rounded,
  };

  @override
  void initState() {
    super.initState();
    _loadCompletedTopics();
  }

  Future<void> _loadCompletedTopics() async {
    final titles = topics[selectedLevel]!.map((t) => t.title);
    final done = await ChatProgressService.completedTitlesFor(
      'conversation',
      titles,
    );
    if (mounted) setState(() => _completedTopics = done);
  }

  final Map<String, List<_ConversationItem>> topics = {
    "A1": [
      const _ConversationItem('Sich vorstellen', Icons.person_outline_rounded),
      const _ConversationItem('Begrüßung', Icons.waving_hand_outlined),
      const _ConversationItem('Familie', Icons.groups_2_outlined),
      const _ConversationItem('Freunde', Icons.group_outlined),
      const _ConversationItem('Hobbys', Icons.sports_esports_outlined),
      const _ConversationItem('Essen', Icons.restaurant_menu_rounded),
      const _ConversationItem('Getränke', Icons.local_drink_outlined),
      const _ConversationItem('Im Restaurant', Icons.lunch_dining_outlined),
      const _ConversationItem('Im Supermarkt', Icons.storefront_outlined),
      const _ConversationItem('Einkaufen', Icons.shopping_bag_outlined),
      const _ConversationItem('Kleidung', Icons.checkroom_outlined),
      const _ConversationItem('Farben', Icons.palette_outlined),
      const _ConversationItem('Zahlen', Icons.pin_rounded),
      const _ConversationItem('Uhrzeit', Icons.schedule_rounded),
      const _ConversationItem('Wochentage', Icons.calendar_today_outlined),
      const _ConversationItem('Monate', Icons.date_range_rounded),
      const _ConversationItem('Wetter', Icons.cloud_outlined),
      const _ConversationItem('Mein Tag', Icons.today_outlined),
      const _ConversationItem('Meine Wohnung', Icons.home_outlined),
      const _ConversationItem('Mein Zimmer', Icons.meeting_room_outlined),
      const _ConversationItem('In der Stadt', Icons.location_city_outlined),
      const _ConversationItem('Weg fragen', Icons.place_outlined),
      const _ConversationItem('Schule', Icons.school_outlined),
      const _ConversationItem('Berufe', Icons.work_outline_rounded),
      const _ConversationItem('Sprachen', Icons.translate_rounded),
      const _ConversationItem('Länder', Icons.public_rounded),
      const _ConversationItem('Im Hotel', Icons.hotel_outlined),
      const _ConversationItem('Am Bahnhof', Icons.train_outlined),
      const _ConversationItem('Im Bus', Icons.directions_bus_outlined),
      const _ConversationItem('Beim Arzt', Icons.local_hospital_outlined),
    ],
    "A2": [
      const _ConversationItem('Reisen', Icons.flight_takeoff_rounded),
      const _ConversationItem('Urlaub', Icons.beach_access_outlined),
      const _ConversationItem('Im Hotel', Icons.hotel_outlined),
      const _ConversationItem('Am Flughafen', Icons.local_airport_outlined),
      const _ConversationItem('Gesundheit', Icons.favorite_border_rounded),
      const _ConversationItem('Beim Arzt', Icons.local_hospital_outlined),
      const _ConversationItem('Sport', Icons.sports_soccer_outlined),
      const _ConversationItem('Freizeit', Icons.celebration_outlined),
      const _ConversationItem('Meine Arbeit', Icons.work_outline_rounded),
      const _ConversationItem('Bewerbung', Icons.description_outlined),
      const _ConversationItem('Einladung', Icons.mail_outline_rounded),
      const _ConversationItem('Feste', Icons.celebration_rounded),
      const _ConversationItem('Geburtstag', Icons.cake_outlined),
      const _ConversationItem('Probleme im Alltag', Icons.error_outline_rounded),
      const _ConversationItem('Internet', Icons.language_rounded),
      const _ConversationItem('Soziale Medien', Icons.groups_outlined),
      const _ConversationItem('Umwelt', Icons.park_outlined),
      const _ConversationItem('Natur', Icons.landscape_outlined),
      const _ConversationItem('Vergangenheit', Icons.history_rounded),
      const _ConversationItem('Meine Erfahrung', Icons.workspace_premium_outlined),
      const _ConversationItem('Meine Kindheit', Icons.child_care_outlined),
      const _ConversationItem('Pläne fürs Wochenende', Icons.event_available_outlined),
      const _ConversationItem('Termine machen', Icons.event_note_outlined),
      const _ConversationItem('Wohnung suchen', Icons.home_work_outlined),
      const _ConversationItem('Nachbarn', Icons.groups_outlined),
      const _ConversationItem('Freundschaft', Icons.favorite_outline_rounded),
      const _ConversationItem('Gefühle', Icons.mood_outlined),
      const _ConversationItem('Missverständnisse', Icons.help_outline_rounded),
      const _ConversationItem('Im Restaurant reservieren', Icons.table_restaurant_outlined),
      const _ConversationItem('Eine Geschichte erzählen', Icons.menu_book_outlined),
    ],
    "B1": [
      const _ConversationItem('Meinung äußern', Icons.record_voice_over_outlined),
      const _ConversationItem('Diskussion', Icons.forum_outlined),
      const _ConversationItem('Small Talk im Büro', Icons.business_center_outlined),
      const _ConversationItem('Arbeit und Karriere', Icons.badge_outlined),
      const _ConversationItem('Studium', Icons.cast_for_education_outlined),
      const _ConversationItem('Berufserfahrung', Icons.workspace_premium_outlined),
      const _ConversationItem('Technologie', Icons.devices_outlined),
      const _ConversationItem('Medien', Icons.perm_media_outlined),
      const _ConversationItem('Nachrichten', Icons.newspaper_outlined),
      const _ConversationItem('Kultur', Icons.theater_comedy_outlined),
      const _ConversationItem('Traditionen', Icons.auto_awesome_outlined),
      const _ConversationItem('Migration', Icons.travel_explore_rounded),
      const _ConversationItem('Integration', Icons.handshake_outlined),
      const _ConversationItem('Umweltprobleme', Icons.forest_outlined),
      const _ConversationItem('Reisen und Erfahrungen', Icons.explore_outlined),
      const _ConversationItem('Zukunftspläne', Icons.map_outlined),
      const _ConversationItem('Ziele im Leben', Icons.track_changes_rounded),
      const _ConversationItem('Stress im Alltag', Icons.psychology_alt_outlined),
      const _ConversationItem('Gesunde Ernährung', Icons.emoji_food_beverage_outlined),
      const _ConversationItem('Sport und Motivation', Icons.fitness_center_outlined),
      const _ConversationItem('Freundschaft und Beziehungen', Icons.favorite_border_rounded),
      const _ConversationItem('Konflikte lösen', Icons.gavel_rounded),
      const _ConversationItem('Regeln in der Gesellschaft', Icons.rule_folder_outlined),
      const _ConversationItem('Ein Problem beschreiben', Icons.report_problem_outlined),
      const _ConversationItem('Eine Präsentation machen', Icons.slideshow_outlined),
      const _ConversationItem('Ein Ereignis erzählen', Icons.event_outlined),
      const _ConversationItem('Vor- und Nachteile', Icons.compare_arrows_rounded),
      const _ConversationItem('Entscheidungen treffen', Icons.fact_check_outlined),
      const _ConversationItem('Im Team arbeiten', Icons.groups_3_outlined),
      const _ConversationItem('Missverständnisse klären', Icons.rule_rounded),
    ],
    "B2": [
      const _ConversationItem('Debatte', Icons.question_answer_outlined),
      const _ConversationItem('Argumentation', Icons.gavel_rounded),
      const _ConversationItem('Kritik äußern', Icons.rate_review_outlined),
      const _ConversationItem('Gesellschaft', Icons.diversity_3_outlined),
      const _ConversationItem('Politik', Icons.account_balance_outlined),
      const _ConversationItem('Wirtschaft', Icons.attach_money_rounded),
      const _ConversationItem('Marketing', Icons.campaign_outlined),
      const _ConversationItem('Management', Icons.manage_accounts_outlined),
      const _ConversationItem('Innovation', Icons.lightbulb_circle_outlined),
      const _ConversationItem('Digitalisierung', Icons.hub_outlined),
      const _ConversationItem('Künstliche Intelligenz', Icons.smart_toy_outlined),
      const _ConversationItem('Klimawandel', Icons.wb_sunny_outlined),
      const _ConversationItem('Umweltpolitik', Icons.energy_savings_leaf_outlined),
      const _ConversationItem('Wissenschaft', Icons.science_outlined),
      const _ConversationItem('Forschung', Icons.biotech_outlined),
      const _ConversationItem('Literatur', Icons.library_books_outlined),
      const _ConversationItem('Psychologie', Icons.psychology_outlined),
      const _ConversationItem('Philosophie', Icons.self_improvement_outlined),
      const _ConversationItem('Ethik', Icons.volunteer_activism_outlined),
      const _ConversationItem('Internationale Beziehungen', Icons.handshake_rounded),
      const _ConversationItem('Startups', Icons.rocket_outlined),
      const _ConversationItem('Karriereplanung', Icons.timeline_rounded),
      const _ConversationItem('Leadership', Icons.groups_3_outlined),
      const _ConversationItem('Verhandlungen', Icons.handshake_outlined),
      const _ConversationItem('Problemlösung', Icons.extension_outlined),
      const _ConversationItem('Rhetorik', Icons.mic_none_rounded),
      const _ConversationItem('Präsentationstechniken', Icons.present_to_all_rounded),
      const _ConversationItem('Entscheidungen begründen', Icons.fact_check_outlined),
      const _ConversationItem('Ein Thema analysieren', Icons.analytics_outlined),
      const _ConversationItem('Komplexe Diskussion führen', Icons.forum_outlined),
    ],
  };

  ChatTheme get _theme => ChatTheme.of(context);

  String _levelDescription(AppLocalizations l, String level) {
    switch (level) {
      case 'A2':
        return l.levelElementary;
      case 'B1':
        return l.levelIntermediate;
      case 'B2':
        return l.levelUpperIntermediate;
      default:
        return l.levelBeginner;
    }
  }

  Future<void> _showLevelPicker() async {
    final l = AppLocalizations.of(context);
    final levels = ['A1', 'A2', 'B1', 'B2'];

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
          decoration: BoxDecoration(
            color: _theme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: _theme.border,
                    borderRadius: BorderRadius.circular(99)),
                ),
                ...levels.map(
                  (level) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        setState(() => selectedLevel = level);
                        await _loadCompletedTopics();
                        if (mounted) Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedLevel == level
                              ? _theme.surfaceSoft
                              : _theme.background,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selectedLevel == level
                                ? AppColors.duoBlue.withValues(alpha: 0.24)
                                : _theme.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: _levelColor(level).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14)),
                              child: Icon(
                                levelIcons[level],
                                color: _levelColor(level),
                                size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    level,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: _theme.textPrimary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _levelDescription(l, level),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: _theme.textSecondary),
                                  ),
                                ]),
                            ),
                            if (selectedLevel == level)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.duoBlue,
                                size: 20),
                          ]),
                      )),
                  )),
              ]),
          ),
        );
      },
    );
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'A1':
        return const Color(0xFF2BB673);
      case 'A2':
        return const Color(0xFF2196F3);
      case 'B1':
        return const Color(0xFFFF9800);
      case 'B2':
        return const Color(0xFFFF5A5F);
      default:
        return AppColors.duoBlue;
    }
  }

  Future<void> _startFreeChat() async {
    final l = AppLocalizations.of(context);
    final prefs = await SharedPreferences.getInstance();
    final userLevel = prefs.getString('userLevel') ?? 'A1';
    final userGoal = prefs.getString('userGoal') ?? 'daily';

    String goalText;
    switch (userGoal) {
      case 'travel':
        goalText = l.goalTravel;
        break;
      case 'study':
        goalText = l.goalStudy;
        break;
      case 'exam':
        goalText = l.goalExam;
        break;
      case 'grammar':
        goalText = l.grammar;
        break;
      default:
        goalText = l.goalDaily;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            title: l.freeChatTitle(userLevel, goalText),
            sourceType: 'conversation',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currentTopics = topics[selectedLevel]!;

    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: _theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _theme.textPrimary,
            size: 22),
        ),
        centerTitle: true,
        title: GestureDetector(
          onTap: _showLevelPicker,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.conversationsLevel(selectedLevel),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white : AppColors.duoTextDark),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: _theme.textPrimary),
            ]),
        )),
      body: Column(
        children: [
          // FREE CHAT KARTASI (YUQORIDA)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: GamifiedCard(
              color: AppColors.duoBlue,
              shadowColor: AppColors.duoBlueShadow,
              shadowDepth: 6,
              padding: const EdgeInsets.all(18),
              onTap: _startFreeChat,
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(16)),
                    child: const Center(
                      child: Text('💬', style: TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.freeConversation,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l.freeChatPickTopic,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70),
                        ),
                      ]),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 24),
                ]),
            )),
          // MAVZULAR RO'YXATI
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
              itemCount: currentTopics.length,
              separatorBuilder: (context, child) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final topic = currentTopics[index];
                final isDone = _completedTopics.contains(topic.title);
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 180 + (index * 18)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 8 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: GamifiedCard(
                    color: isDark
                        ? AppColors.duoCardGray.withValues(alpha: 0.1)
                        : Colors.white,
                    shadowColor:
                        isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                    shadowDepth: 4,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            title: topic.title,
                            sourceType: 'conversation',
                            initiallyCompleted: isDone),
                        ),
                      );
                      await _loadCompletedTopics();
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _levelColor(selectedLevel)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _levelColor(selectedLevel)
                                  .withValues(alpha: 0.35),
                              width: 1.5),
                          ),
                          child: Icon(
                            topic.icon,
                            color: _levelColor(selectedLevel),
                            size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topic.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _theme.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l.conversationSubtitle(topic.title),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: _theme.textSecondary),
                              ),
                            ]),
                        ),
                        if (isDone)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.duoGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.duoGreen,
                                width: 1.2),
                            ),
                            child: Text(
                              l.completedBadge,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppColors.duoGreen,
                                letterSpacing: 0.2),
                            ),
                          )
                        else
                          Icon(
                            Icons.chevron_right_rounded,
                            color: _theme.textSecondary,
                            size: 22),
                      ]),
                  ),
                );
              }),
          ),
        ]),
    );
  }
}

class _ConversationItem {
  final String title;
  final IconData icon;

  const _ConversationItem(this.title, this.icon);
}
