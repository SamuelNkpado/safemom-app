import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        return Scaffold(
          backgroundColor: AppColors.cream,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
                vertical: AppSpacing.pageTop,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(user),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPregnancyCard(user),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Quick actions', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.md),
                  _buildQuickActions(context),
                  const SizedBox(height: AppSpacing.lg),
                  _buildWeeklyTipCard(user),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(User? user) {
    final firstName = _firstName(user?.name);
    final initials = _initials(user?.name);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Habari, $firstName 👋', style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "Today's check-in",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.softTeal,
          child: Text(
            initials,
            style: AppTextStyles.body.copyWith(
              color: AppColors.teal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPregnancyCard(User? user) {
    final week = user?.currentWeek ?? 0;
    final trimester = _trimesterLabel(week);
    final weeksToGo = week > 0 ? (40 - week).clamp(0, 40) : 0;
    final progress = week > 0 ? (week / 40).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();
    final size = _babySize(week);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your pregnancy',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  week > 0 ? 'Week $week' : 'Getting started',
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  week > 0
                      ? '$trimester · $weeksToGo weeks to go'
                      : 'Complete onboarding to see your progress',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (size != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(size, style: AppTextStyles.body),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: AppColors.borderDefault,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.teal,
                    ),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: '🌿',
            label: 'Log symptom',
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.symptomLog,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickAction(
            icon: '😊',
            label: 'Log mood',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyTipCard(User? user) {
    final week = user?.currentWeek ?? 0;
    final tip = _weeklyTipFor(week);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY TIP',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.coral,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(tip.title, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          Text(
            tip.body,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- helpers ----------

  String _firstName(String? full) {
    if (full == null || full.trim().isEmpty) return 'Mama';
    return full.trim().split(RegExp(r'\s+')).first;
  }

  String _initials(String? full) {
    if (full == null || full.trim().isEmpty) return 'M';
    final parts = full.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String _trimesterLabel(int week) {
    if (week <= 13) return '1st trimester';
    if (week <= 27) return '2nd trimester';
    return '3rd trimester';
  }

  String? _babySize(int week) {
    if (week == 0) return null;
    if (week <= 4) return 'Baby is the size of a poppy seed 🌱';
    if (week <= 8) return 'Baby is the size of a raspberry 🫐';
    if (week <= 12) return 'Baby is the size of a lime 🍋';
    if (week <= 16) return 'Baby is the size of an avocado 🥑';
    if (week <= 20) return 'Baby is the size of a banana 🍌';
    if (week <= 24) return 'Baby is the size of a corn cob 🌽';
    if (week <= 28) return 'Baby is the size of an eggplant 🍆';
    if (week <= 32) return 'Baby is the size of a squash 🎃';
    if (week <= 36) return 'Baby is the size of a papaya 🍈';
    return 'Baby is fully grown 👶';
  }

  _TipContent _weeklyTipFor(int week) {
    if (week <= 12) {
      return const _TipContent(
        title: 'Rest when you feel tired',
        body:
        'Fatigue is normal in the first trimester. Short naps and early bedtime help your body build the placenta.',
      );
    }
    if (week <= 27) {
      return const _TipContent(
        title: 'Foods that help iron levels',
        body:
        'Sukuma wiki, beans, and beef liver are all rich in iron and easy to find in most local markets.',
      );
    }
    return const _TipContent(
      title: 'Practise gentle breathing exercises',
      body:
      'Deep breathing helps manage back pain and prepares you for labour. Try 4-in, 6-out for 5 minutes daily.',
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: AppTextStyles.h2),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.body,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipContent {
  final String title;
  final String body;

  const _TipContent({required this.title, required this.body});
}