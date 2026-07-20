import 'package:flutter/material.dart';
import 'package:safemom/core/constants/app_colors.dart';
import 'package:safemom/core/constants/app_spacing.dart';
import 'package:safemom/core/theme/app_text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Habari, Amina 👋', style: AppTextStyles.h1),
                      Text(
                        "Today's check-in",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  // Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.softTeal,
                    child: Text(
                      'AW',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Pregnancy Week Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your pregnancy',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Week 24', style: AppTextStyles.h2),
                            Text(
                              '2nd trimester · 16 weeks to go',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Baby is the size of a corn cob 🌽',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                        // Progress Circle
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: 0.6,
                                backgroundColor: AppColors.borderDefault,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.teal,
                                ),
                                strokeWidth: 6,
                              ),
                            ),
                            Text(
                              '60%',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.teal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'complete',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Quick Actions
              Text('Quick actions', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      emoji: '🩺',
                      label: 'Log symptom',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _QuickActionButton(
                      emoji: '😊',
                      label: 'Log mood',
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Weekly Tip Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
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
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Foods that help iron levels',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Sukuma wiki, beans, and beef liver are all rich in iron and easy to find...',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
}

// Quick Action Button Widget
class _QuickActionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
