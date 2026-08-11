import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/gamified_card.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/app_localizations.dart';
import 'admin_group_detail_screen.dart';

class AdminCourseGroupsScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const AdminCourseGroupsScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<AdminCourseGroupsScreen> createState() => _AdminCourseGroupsScreenState();
}

class _AdminCourseGroupsScreenState extends State<AdminCourseGroupsScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedStartDate;
  final TextEditingController _durationController = TextEditingController();

  final List<Color> colorOptions = [
    AppColors.duoBlue,
    AppColors.duoGreen,
    AppColors.duoOrange,
    AppColors.duoPurple,
    AppColors.duoRed,
  ];
  Color _selectedColor = AppColors.duoBlue;

  void _deleteGroup(String groupId, String groupName, List students) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    // Talabalar bo'lsa ogohlantirish
    final hasStudents = students.isNotEmpty;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2A32) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_rounded, size: 48, color: AppColors.duoRed),
              const SizedBox(height: 16),
              Text(
                '$groupName guruhini o\'chirmoqchimisiz?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                ),
              ),
              if (hasStudents) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.duoOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Bu guruhda ${students.length} ta talaba bor! Ularni avval guruhdan chiqarish kerak.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.duoOrange,
                    ),
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Bu amalni qaytarib bo\'lmaydi.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : AppColors.duoTextLight,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l.cancel, style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white70 : AppColors.duoTextDark,
                      )),
                    ),
                  ),
                  if (!hasStudents) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: Text(l.delete, style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.duoRed,
                        )),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddGroupDialog(bool isDark) {
    _nameController.clear();
    _selectedStartDate = null;
    _durationController.clear();
    _selectedColor = colorOptions.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: BoxDecoration(
                color: isDark ? AppColors.duoCardGray : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : AppColors.duoCardGray,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context).newGroupTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDialogField(_nameController, AppLocalizations.of(context).groupNameHint, isDark),
                    const SizedBox(height: 12),
                    // Date Picker field
                    StatefulBuilder(
                      builder: (ctx, setDateState) => GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            builder: (ctx, child) => Theme(
                              data: isDark
                                  ? ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(primary: AppColors.duoBlue),
                                    )
                                  : ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(primary: AppColors.duoBlue),
                                    ),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            setModalState(() => _selectedStartDate = picked);
                            setDateState(() {});
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black12 : AppColors.duoBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  color: isDark ? Colors.white54 : AppColors.duoTextLight, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                _selectedStartDate == null
                                    ? AppLocalizations.of(context).selectStartDate
                                    : '${_selectedStartDate!.day.toString().padLeft(2, '0')}.${_selectedStartDate!.month.toString().padLeft(2, '0')}.${_selectedStartDate!.year}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _selectedStartDate == null
                                      ? (isDark ? Colors.white54 : AppColors.duoTextLight)
                                      : (isDark ? Colors.white : AppColors.duoTextDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Davomiyligi (oy soni)',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : AppColors.duoTextLight,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.black12 : AppColors.duoBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        suffixText: 'oy',
                        suffixStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : AppColors.duoTextLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context).selectColor,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: colorOptions.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () => setModalState(() => _selectedColor = color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? (isDark ? Colors.white : AppColors.duoTextDark) : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: GamifiedCard(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        color: AppColors.duoGreen,
                        shadowColor: AppColors.duoGreenShadow,
                        shadowDepth: 5,
                        onTap: () async {
                          final name = _nameController.text.trim();
                          final duration = _durationController.text.trim();
                          if (name.isEmpty || _selectedStartDate == null || duration.isEmpty) return;
                          
                          final startedStr = '${_selectedStartDate!.day.toString().padLeft(2,'0')}.${_selectedStartDate!.month.toString().padLeft(2,'0')}.${_selectedStartDate!.year}';
                          
                          await FirebaseService().addGroup(
                            courseId: widget.courseId,
                            courseTitle: widget.courseTitle,
                            name: name,
                            duration: duration,
                            startDate: startedStr,
                            color: _selectedColor.toARGB32(),
                          );
                          
                          if (bottomSheetContext.mounted) Navigator.pop(bottomSheetContext);
                        },
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context).save,
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, bool isDark) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : AppColors.duoTextDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : AppColors.duoTextLight,
        ),
        filled: true,
        fillColor: isDark ? Colors.black12 : AppColors.duoBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text(
          widget.courseTitle.toUpperCase(),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.duoTextDark,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.duoTextDark),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_group_fab',
        onPressed: () => _showAddGroupDialog(isDark),
        backgroundColor: AppColors.duoGreen,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirebaseService().getGroupsStream(widget.courseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.duoBlue));
          }

          final groups = snapshot.data ?? [];

          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('👥', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'Hali guruhlar yo\'q',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.duoTextLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final data = groups[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GamifiedCard(
                  padding: const EdgeInsets.all(20),
                  color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                  shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminGroupDetailScreen(
                          groupId: data['id'],
                          groupName: data['name'] ?? 'Noma\'lum',
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Color(data['color'] ?? AppColors.duoBlue.toARGB32()).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(child: Text('👥', style: TextStyle(fontSize: 26))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              (data['name'] ?? 'Noma\'lum').toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.duoTextDark,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white54 : AppColors.duoTextLight),
                          IconButton(
                            onPressed: () => _deleteGroup(data['id'], data['name'] ?? '', data['students'] as List? ?? []),
                            icon: Icon(Icons.delete_outline_rounded, color: AppColors.duoRed, size: 22),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildInfoBox('🧑‍🎓', 'Studentlar', '${(data['students'] as List?)?.length ?? 0} ta', Color(data['color'] ?? AppColors.duoBlue.toARGB32()), isDark),
                          const SizedBox(width: 10),
                          _buildInfoBox('📅', 'Boshlangan', data['started'] ?? '', Color(data['color'] ?? AppColors.duoBlue.toARGB32()), isDark),
                          const SizedBox(width: 10),
                          _buildInfoBox('⏱️', 'Davomiyligi', data['duration'] ?? '', Color(data['color'] ?? AppColors.duoBlue.toARGB32()), isDark),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoBox(String emoji, String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.duoTextDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}