import 'package:flutter/material.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/locale_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/safe_bottom_sheet.dart';
import '../../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart' as user_provider;
import '../../services/haptic_service.dart';

// Re-export for convenience
export '../../utils/theme_manager.dart' show AccentPreset, accentPresets;

class StudentSettingsScreen extends StatefulWidget {
  const StudentSettingsScreen({super.key});

  @override
  State<StudentSettingsScreen> createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {
  bool _isDarkMode = false;
  bool _isVibrationOn = true;
  bool _isLanguageExpanded = false;

  // Mock user data (fallback only)
  final String _userName = 'Alisher Karimov';

  void _showEditDialog(BuildContext context, userProvider, bool isDark) {
    final l = AppLocalizations.of(context);
    final nameCtrl = TextEditingController(text: userProvider.name);
    final phoneCtrl = TextEditingController(text: userProvider.phone);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeBottomSheet.scrollable(
        context: ctx,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 50, height: 6,
                decoration: BoxDecoration(color: AppColors.duoCardGrayShadow, borderRadius: BorderRadius.circular(20)))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(l.editProfileCaps, style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark)),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit_rounded, color: AppColors.duoBlue, size: 20),
                ],
              ),
              const SizedBox(height: 20),
              _editField(nameCtrl, 'Ism Familiya', isDark),
              const SizedBox(height: 12),
              _editField(phoneCtrl, l.phoneNumber, isDark, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black12 : AppColors.duoBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  const Icon(Icons.lock_outline_rounded, color: AppColors.duoTextLight, size: 18),
                  const SizedBox(width: 10),
                  Text(userProvider.email,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.duoTextLight)),
                  const Spacer(),
                  const Icon(Icons.lock_rounded, size: 18, color: AppColors.duoTextLight),
                ]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await userProvider.updateProfile(
                      fullName: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.duoGreen,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: Text(l.saveBtn,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editField(TextEditingController ctrl, String label, bool isDark,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.duoTextDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white54 : AppColors.duoTextLight),
        filled: true,
        fillColor: isDark ? Colors.black12 : AppColors.duoBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _isDarkMode = ThemeManager.isDark;
    _isVibrationOn = HapticService.isEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ThemeManager.scaffoldBg(context),
      appBar: AppBar(
        title: Text(
          l.settingsTitle,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ThemeManager.textColor(context),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: ThemeManager.cardColor(context),
            boxShadow: ThemeManager.cardShadow(context, const Color(0xFF5C6BC0).withValues(alpha: 0.12)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF5C6BC0), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          _buildProfileTile(),
          const SizedBox(height: 14),
          _buildLanguageTile(),
          const SizedBox(height: 14),
          _buildAccentColorTile(),
          const SizedBox(height: 14),
          _buildDarkModeTile(),
          const SizedBox(height: 14),
          _buildVibrationTile(),
          const SizedBox(height: 14),
          _buildAboutTile(),
        ],
      ),
    );
  }

  Widget _buildProfileTile() {
    final isDark = ThemeManager.isDark;
    return GamifiedCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      onTap: () {
        final userProvider = Provider.of<user_provider.UserProvider>(context, listen: false);
        _showEditDialog(context, userProvider, isDark);
      },
      child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    ThemeManager.iconBgColor(context, const Color(0xFF5C6BC0).withValues(alpha: 0.15)),
                    ThemeManager.iconBgColor(context, const Color(0xFF5C6BC0).withValues(alpha: 0.05)),
                  ],
                ),
              ),
              child: const Icon(Icons.person_outline_rounded, color: Color(0xFF5C6BC0), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).profileInfo,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ThemeManager.textColor(context)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Provider.of<user_provider.UserProvider>(context).name.isNotEmpty
                        ? Provider.of<user_provider.UserProvider>(context).name
                        : _userName,
                    style: TextStyle(fontSize: 13, color: ThemeManager.subTextColor(context)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white54 : const Color(0xFF2D3142).withValues(alpha: 0.3)),
          ],
        ),
    );
  }

  Widget _buildLanguageTile() {
    final l = AppLocalizations.of(context);
    final currentLocale = LocaleManager.currentLocale.value;
    final isDark = ThemeManager.isDark;
    return GamifiedCard(
      padding: EdgeInsets.zero,
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isLanguageExpanded = !_isLanguageExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [
                          ThemeManager.iconBgColor(context, const Color(0xFF43A047).withValues(alpha: 0.15)),
                          ThemeManager.iconBgColor(context, const Color(0xFF43A047).withValues(alpha: 0.05)),
                        ],
                      ),
                    ),
                    child: const Icon(Icons.language_rounded, color: Color(0xFF43A047), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.appLanguage,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ThemeManager.textColor(context)),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (currentLocale.imagePath != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Image.asset(
                                  currentLocale.imagePath!,
                                  width: 20,
                                  height: 14,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ] else if (currentLocale.flagEmoji != null) ...[
                              Text(
                                currentLocale.flagEmoji!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              currentLocale.nativeName,
                              style: TextStyle(fontSize: 13, color: ThemeManager.subTextColor(context)),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF43A047).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                currentLocale.label,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF43A047),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isLanguageExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: isDark ? Colors.white54 : const Color(0xFF2D3142).withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isLanguageExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: AppLocale.values.map((locale) {
                        final isSelected = currentLocale == locale;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _isLanguageExpanded = false);
                            LocaleManager.setLocale(locale);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations(locale.code).languageChanged),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: isSelected
                                  ? const Color(0xFF43A047).withValues(alpha: 0.1)
                                  : ThemeManager.scaffoldBg(context),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF43A047)
                                    : Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : const Color(0xFFE8E8E8),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Flag image or emoji
                                if (locale.imagePath != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.asset(
                                      locale.imagePath!,
                                      width: 28,
                                      height: 20,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else if (locale.flagEmoji != null)
                                  Text(
                                    locale.flagEmoji!,
                                    style: const TextStyle(fontSize: 20),
                                  )
                                else
                                  const SizedBox(width: 28),
                                const SizedBox(width: 12),
                                // Language code badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF43A047).withValues(alpha: 0.15)
                                        : ThemeManager.iconBgColor(context, const Color(0xFFE0E0E0)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    locale.label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? const Color(0xFF43A047)
                                          : ThemeManager.subTextColor(context),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Native name
                                Expanded(
                                  child: Text(
                                    locale.nativeName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFF43A047)
                                          : ThemeManager.textColor(context),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF43A047), size: 20),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccentColorTile() {
    final isDark = ThemeManager.isDark;
    return ValueListenableBuilder<AccentPreset>(
      valueListenable: ThemeManager.accentNotifier,
      builder: (context, current, _) {
        return GamifiedCard(
          padding: const EdgeInsets.all(16),
          color: isDark
              ? AppColors.duoCardGray.withValues(alpha: 0.1)
              : Colors.white,
          shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
          onTap: () => _showAccentPicker(context, isDark, current),
          child: Row(
            children: [
              // Icon container with current accent color
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: current.color.withValues(alpha: 0.15),
                ),
                child: Icon(Icons.palette_rounded, color: current.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Asosiy rang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ThemeManager.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Mini color dots preview
                    Row(
                      children: accentPresets.map((p) {
                        final isSelected = p.id == current.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: isSelected ? 18 : 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: p.color,
                              borderRadius: BorderRadius.circular(6),
                              border: isSelected
                                  ? Border.all(color: p.shadow, width: 2)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? Colors.white54
                    : const Color(0xFF2D3142).withValues(alpha: 0.3),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAccentPicker(
      BuildContext context, bool isDark, AccentPreset current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AccentPickerSheet(isDark: isDark, current: current),
    );
  }

  Widget _buildDarkModeTile() {    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    return GamifiedCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  ThemeManager.iconBgColor(context, const Color(0xFF7B1FA2).withValues(alpha: 0.15)),
                  ThemeManager.iconBgColor(context, const Color(0xFF7B1FA2).withValues(alpha: 0.05)),
                ],
              ),
            ),
            child: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: const Color(0xFF7B1FA2), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isDark ? l.darkMode : l.lightMode, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ThemeManager.textColor(context))),
                Text(l.changeTheme, style: TextStyle(fontSize: 13, color: ThemeManager.subTextColor(context))),
              ],
            ),
          ),
          ThemeSwitcher(
            clipper: const ThemeSwitcherCircleClipper(),
            builder: (context) {
              return DayNightSwitch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() => _isDarkMode = value);
                  ThemeManager.toggleTheme(value);
                  ThemeSwitcher.of(context).changeTheme(
                    theme: value ? ThemeManager.darkTheme : ThemeManager.lightTheme,
                    isReversed: !value,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? l.darkModeOn : l.lightModeOn),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVibrationTile() {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    return GamifiedCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  ThemeManager.iconBgColor(context, const Color(0xFFFF7043).withValues(alpha: 0.15)),
                  ThemeManager.iconBgColor(context, const Color(0xFFFF7043).withValues(alpha: 0.05)),
                ],
              ),
            ),
            child: const Icon(Icons.vibration_rounded, color: Color(0xFFFF7043), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.vibration, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ThemeManager.textColor(context))),
                Text(l.vibrationDesc, style: TextStyle(fontSize: 13, color: ThemeManager.subTextColor(context))),
              ],
            ),
          ),
          VibrationSwitch(
            value: _isVibrationOn,
            onChanged: (value) {
              setState(() => _isVibrationOn = value);
              HapticService.setEnabled(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTile() {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    return GamifiedCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      onTap: () => _showAboutDialog(),
      child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    ThemeManager.iconBgColor(context, const Color(0xFF4FC3F7).withValues(alpha: 0.15)),
                    ThemeManager.iconBgColor(context, const Color(0xFF4FC3F7).withValues(alpha: 0.05)),
                  ],
                ),
              ),
              child: const Icon(Icons.info_outline_rounded, color: Color(0xFF4FC3F7), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.about, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ThemeManager.textColor(context))),
                  Text(l.versionInfo, style: TextStyle(fontSize: 13, color: ThemeManager.subTextColor(context))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white54 : const Color(0xFF2D3142).withValues(alpha: 0.3)),
          ],
        ),
    );
  }

  void _showAboutDialog() {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: ThemeManager.cardColor(context),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFF5C6BC0).withValues(alpha: 0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5C6BC0).withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(3, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(colors: [Color(0xFF5C6BC0), Color(0xFF7C4DFF)]),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5C6BC0).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(2, 5),
                        ),
                      ],
                    ),
                    child: const Center(child: Icon(Icons.cruelty_free_rounded, color: Colors.white, size: 24)),
                  ),
                  const SizedBox(width: 12),
                  Text('Berlin-Nukus', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ThemeManager.textColor(context))),
                ],
              ),
              const SizedBox(height: 20),
              const _AboutRow(icon: Icons.code_rounded, text: 'Versiya: 1.0.0'),
              const SizedBox(height: 8),
              const _AboutRow(icon: Icons.calendar_today_rounded, text: 'So\'ngi yangilanish: 2026'),
              const SizedBox(height: 8),
              const _AboutRow(icon: Icons.person_rounded, text: 'Dasturchi: Berlin-Nukus Team'),
              const SizedBox(height: 8),
              const _AboutRow(icon: Icons.email_rounded, text: 'Email: info@berlinnukus.uz'),
              const SizedBox(height: 8),
              const _AboutRow(icon: Icons.phone_rounded, text: 'Tel: +998 90 123 45 67'),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: ThemeManager.isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE8E8E8),
              ),
              const SizedBox(height: 12),
              Text(
                '© 2026 Berlin-Nukus. Barcha huquqlar himoyalangan.',
                style: TextStyle(
                  fontSize: 11,
                  color: ThemeManager.subTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(colors: [Color(0xFF5C6BC0), Color(0xFF7C4DFF)]),
                    ),
                    child: Center(
                      child: Text(l.close, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AboutRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(fontSize: 13, color: ThemeManager.textColor(context))),
      ],
    );
  }
}

class DayNightSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const DayNightSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: value
                ? [const Color(0xFF111C2E), const Color(0xFF1D2C42)] // Night navy gradient
                : [const Color(0xFF5A96E3), const Color(0xFF82B1EC)], // Day sky blue gradient
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Clouds for Day Mode (fade out in night mode)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                right: value ? -40 : -10,
                bottom: value ? -30 : -12,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: value ? 0.0 : 0.7,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // Cloud layer 1
                      Container(
                        width: 50,
                        height: 35,
                        decoration: const BoxDecoration(
                          color: Color(0x66FFFFFF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Cloud layer 2
                      Positioned(
                        right: 12,
                        bottom: -5,
                        child: Container(
                          width: 40,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Color(0xB2FFFFFF),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Cloud layer 3
                      Positioned(
                        right: -5,
                        bottom: -8,
                        child: Container(
                          width: 32,
                          height: 25,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Clouds for Night Mode (fade in in night mode)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                left: value ? -10 : -45,
                bottom: value ? -10 : -25,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: value ? 0.7 : 0.0,
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      // Dark Cloud layer 1
                      Container(
                        width: 45,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0x662C3E50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Dark Cloud layer 2
                      Positioned(
                        left: 10,
                        bottom: -4,
                        child: Container(
                          width: 38,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xB234495E),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Thumb (Sun / Moon)
              AnimatedAlign(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                    child: value
                        ? _buildMoon() // Night: Moon
                        : _buildSun(), // Day: Sun
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSun() {
    return Container(
      key: const ValueKey('sun'),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFCA28).withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFEE58), // Light yellow
            Color(0xFFF57F17), // Deep golden orange
          ],
        ),
      ),
    );
  }

  Widget _buildMoon() {
    return Container(
      key: const ValueKey('moon'),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCFD8DC).withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFECEFF1), // Silver white
            Color(0xFFB0BEC5), // Blue grey
          ],
        ),
      ),
      child: Stack(
        children: [
          // Crater 1
          Positioned(
            top: 7,
            right: 7,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF78909C).withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Crater 2
          Positioned(
            bottom: 6,
            left: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF78909C).withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Crater 3
          Positioned(
            bottom: 12,
            right: 8,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF78909C).withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VibrationSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const VibrationSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: value
                ? [const Color(0xFFFF5722), const Color(0xFFFF8A65)] // Energetic orange gradient
                : [const Color(0xFF78909C), const Color(0xFFB0BEC5)], // Silent grey gradient
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Wave Ripples for Active Mode (fade out in inactive mode)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOut,
                left: value ? 12 : -20,
                top: 8,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: value ? 0.35 : 0.0,
                  child: const Row(
                    children: [
                      _WaveLine(height: 14, thickness: 1.5),
                      SizedBox(width: 4),
                      _WaveLine(height: 22, thickness: 2.0),
                      SizedBox(width: 4),
                      _WaveLine(height: 14, thickness: 1.5),
                    ],
                  ),
                ),
              ),

              // Silent diagonal crossed indicator for Inactive Mode
              AnimatedPositioned(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOut,
                right: value ? -20 : 12,
                top: 10,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: value ? 0.0 : 0.4,
                  child: const Icon(
                    Icons.notifications_off_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              // Thumb (Phone/Vibe Indicator)
              AnimatedAlign(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: (value ? const Color(0xFFFF5722) : const Color(0xFF78909C))
                              .withValues(alpha: 0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: value
                          ? const Icon(
                              Icons.vibration_rounded,
                              key: ValueKey('vibe_on'),
                              color: Color(0xFFFF5722),
                              size: 18,
                            )
                          : const Icon(
                              Icons.portable_wifi_off_rounded,
                              key: ValueKey('vibe_off'),
                              color: Color(0xFF78909C),
                              size: 18,
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
  }
}

class _WaveLine extends StatelessWidget {
  final double height;
  final double thickness;

  const _WaveLine({required this.height, required this.thickness});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: thickness,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(thickness / 2),
      ),
    );
  }
}

// ── Accent Color Picker Sheet ─────────────────────────────────────────────────

class _AccentPickerSheet extends StatefulWidget {
  final bool isDark;
  final AccentPreset current;

  const _AccentPickerSheet({required this.isDark, required this.current});

  @override
  State<_AccentPickerSheet> createState() => _AccentPickerSheetState();
}

class _AccentPickerSheetState extends State<_AccentPickerSheet>
    with SingleTickerProviderStateMixin {
  late AccentPreset _selected;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white54 : AppColors.duoTextLight;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 46,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : AppColors.duoCardGrayShadow,
                borderRadius: BorderRadius.circular(99),
              ),
            ),

            // Title
            Row(
              children: [
                Icon(Icons.palette_rounded, color: _selected.color, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Asosiy rang tanlang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Barcha ekranlardagi asosiy rang o\'zgaradi',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Color cards
            ...accentPresets.map((preset) {
              final isSelected = preset.id == _selected.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () async {
                    setState(() => _selected = preset);
                    await ThemeManager.setAccent(preset);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isSelected
                          ? preset.color.withValues(alpha: isDark ? 0.2 : 0.1)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : AppColors.duoBackground),
                      border: Border.all(
                        color: isSelected
                            ? preset.color
                            : (isDark
                                ? Colors.white12
                                : AppColors.duoCardGrayShadow),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: preset.shadow.withValues(alpha: 0.3),
                                offset: const Offset(0, 4),
                                blurRadius: 12,
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Color circle with shadow
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: preset.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: preset.shadow, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: preset.shadow.withValues(alpha: 0.5),
                                offset: const Offset(0, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                preset.nameUz,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isSelected
                                      ? preset.color
                                      : textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Mini gradient bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        preset.color,
                                        preset.shadow,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: isSelected
                              ? Container(
                                  key: const ValueKey('check'),
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: preset.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: preset.shadow, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: preset.shadow
                                            .withValues(alpha: 0.4),
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                )
                              : Container(
                                  key: const ValueKey('empty'),
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white24
                                          : AppColors.duoCardGrayShadow,
                                      width: 2,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}