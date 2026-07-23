import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/user_preferences.dart' as prefs_entity;
import '../../domain/repositories/preferences_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  prefs_entity.UserPreferences? _prefs;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final repo = getIt<PreferencesRepository>();
      final prefs = await repo.getPreferences();
      if (mounted) {
        setState(() {
          _prefs = prefs;
          _loadingPrefs = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _prefs = prefs_entity.UserPreferences.defaults();
          _loadingPrefs = false;
        });
      }
    }
  }

  Future<void> _pickLanguage() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => _LanguageSheet(current: _prefs?.languageCode ?? 'en'),
    );
    if (result == null || _prefs == null) return;
    final repo = getIt<PreferencesRepository>();
    await repo.setLanguage(result);
    if (!mounted) return;
    setState(() => _prefs = _prefs!.copyWith(languageCode: result));
    _showSnack('Language updated');
  }

  Future<void> _pickTheme() async {
    final result = await showModalBottomSheet<prefs_entity.ThemeMode>(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => _ThemeSheet(
        current: _prefs?.themeMode ?? prefs_entity.ThemeMode.light,
      ),
    );
    if (result == null || _prefs == null) return;
    final repo = getIt<PreferencesRepository>();
    await repo.setThemeMode(result);
    if (!mounted) return;
    setState(() => _prefs = _prefs!.copyWith(themeMode: result));
    _showSnack('Theme updated');
  }

  Future<void> _toggleNotifications(bool enabled) async {
    if (_prefs == null) return;
    final repo = getIt<PreferencesRepository>();
    await repo.setNotificationsEnabled(enabled);
    if (!mounted) return;
    setState(() => _prefs = _prefs!.copyWith(notificationsEnabled: enabled));
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(color: AppColors.textOnColor),
        ),
        backgroundColor: AppColors.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleSignOut() {
    debugPrint('SIGN OUT: button tapped');
    final bloc = context.read<AuthBloc>();
    debugPrint(
      'SIGN OUT: current state = ${bloc.state.status}, isClosed = ${bloc.isClosed}',
    );

    if (bloc.isClosed) {
      debugPrint('SIGN OUT: bloc is closed, navigating directly');
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        AppRoutes.welcome,
            (route) => false,
      );
      return;
    }

    bloc.add(const AuthSignOutRequested());
    debugPrint('SIGN OUT: event dispatched');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
      previous.status != current.status &&
          current.status == AuthStatus.unauthenticated,
      listener: (context, state) {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          AppRoutes.welcome,
              (route) => false,
        );
      },
      builder: (context, state) {
        final user = state.user;
        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            backgroundColor: AppColors.cream,
            elevation: 0,
            title: Text('Me', style: AppTextStyles.h2),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Settings', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.md),
                  _buildSettingsCard(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSignOutButton(),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(User? user) {
    final name = user?.name ?? 'Mama';
    final week = user?.currentWeek ?? 0;
    final initials = _initials(name);
    final trimester = _trimesterLabel(week);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.softTeal,
            child: Text(
              initials,
              style: AppTextStyles.h1.copyWith(color: AppColors.teal),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(name, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          Text(
            week > 0 ? 'Week $week · $trimester' : 'Complete onboarding',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    if (_loadingPrefs) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final p = _prefs!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          _SettingsSwitchRow(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            value: p.notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
          _SettingsTapRow(
            icon: Icons.language_outlined,
            label: 'Language',
            value: p.languageCode == 'sw' ? 'Kiswahili' : 'English',
            onTap: _pickLanguage,
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
          _SettingsTapRow(
            icon: Icons.dark_mode_outlined,
            label: 'Theme',
            value: _themeLabel(p.themeMode),
            onTap: _pickTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _handleSignOut,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.coral, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        child: Text(
          'Sign out',
          style: AppTextStyles.button.copyWith(color: AppColors.coral),
        ),
      ),
    );
  }

  // ---------- helpers ----------

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'M';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String _trimesterLabel(int week) {
    if (week <= 0) return '';
    if (week <= 13) return '1st Trimester';
    if (week <= 27) return '2nd Trimester';
    return '3rd Trimester';
  }

  String _themeLabel(prefs_entity.ThemeMode mode) {
    switch (mode) {
      case prefs_entity.ThemeMode.light:
        return 'Light';
      case prefs_entity.ThemeMode.dark:
        return 'Dark';
      case prefs_entity.ThemeMode.system:
        return 'System';
    }
  }
}

// ============================================================
// Row widgets
// ============================================================

class _SettingsTapRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SettingsTapRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: AppColors.teal),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            Text(
              value,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.teal),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.teal,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Bottom sheets
// ============================================================

class _LanguageSheet extends StatelessWidget {
  final String current;
  const _LanguageSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Text('Language', style: AppTextStyles.h2),
            ),
            _sheetOption(context, code: 'en', label: 'English'),
            _sheetOption(context, code: 'sw', label: 'Kiswahili'),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption(
      BuildContext context, {
        required String code,
        required String label,
      }) {
    final selected = code == current;
    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? AppColors.teal : AppColors.textTertiary,
      ),
      title: Text(label, style: AppTextStyles.body),
      onTap: () => Navigator.of(context).pop(code),
    );
  }
}

class _ThemeSheet extends StatelessWidget {
  final prefs_entity.ThemeMode current;
  const _ThemeSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Text('Theme', style: AppTextStyles.h2),
            ),
            _sheetOption(
              context,
              mode: prefs_entity.ThemeMode.light,
              label: 'Light',
            ),
            _sheetOption(
              context,
              mode: prefs_entity.ThemeMode.dark,
              label: 'Dark',
            ),
            _sheetOption(
              context,
              mode: prefs_entity.ThemeMode.system,
              label: 'System',
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption(
      BuildContext context, {
        required prefs_entity.ThemeMode mode,
        required String label,
      }) {
    final selected = mode == current;
    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? AppColors.teal : AppColors.textTertiary,
      ),
      title: Text(label, style: AppTextStyles.body),
      onTap: () => Navigator.of(context).pop(mode),
    );
  }
}