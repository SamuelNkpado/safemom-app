import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// Confirmation screen shown after password reset email is sent.
/// User sees: success message, email recap, instructions, and CTA to go back to login.
class ResetPasswordConfirmationPage extends StatelessWidget {
  const ResetPasswordConfirmationPage({
    super.key,
    required this.email,
  });

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.pageTop,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success icon circle
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.softTeal,
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.checkCircle,
                      size: 60,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Heading
              Text(
                'Check your email',
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),

              // Subtitle
              Text(
                'We\'ve sent a password reset link to:',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Email recap (highlighted card)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.softTeal,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.teal, width: 1),
                ),
                child: Text(
                  email,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Instructions
              Text(
                'Next steps:',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.md),
              _InstructionItem(
                number: 1,
                text: 'Open your email inbox',
              ),
              const SizedBox(height: AppSpacing.md),
              _InstructionItem(
                number: 2,
                text: 'Click the reset link in the email',
              ),
              const SizedBox(height: AppSpacing.md),
              _InstructionItem(
                number: 3,
                text: 'Create a new password and sign in',
              ),
              const SizedBox(height: AppSpacing.xl),

              // Info banner (spam folder reminder)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.softCoral,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.coral, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      LucideIcons.alertCircle,
                      color: AppColors.coral,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Didn\'t receive it? Check your spam folder.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Spacer to push button to bottom
              const Spacer(),

              // Back to login button
              PrimaryButton(
                label: 'Back to login',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper widget for numbered instruction items.
class _InstructionItem extends StatelessWidget {
  const _InstructionItem({
    required this.number,
    required this.text,
  });

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number badge
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.teal,
          ),
          child: Center(
            child: Text(
              '$number',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textOnColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Text
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: AppTextStyles.body,
            ),
          ),
        ),
      ],
    );
  }
}