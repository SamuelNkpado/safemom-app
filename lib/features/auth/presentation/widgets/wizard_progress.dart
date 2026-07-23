import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "Step X of N" label with a segmented progress bar, matching the sign-up
/// wizard header in the Figma.
class WizardProgress extends StatelessWidget {
  const WizardProgress({
    super.key,
    required this.step,
    required this.total,
    this.onBack,
  });

  final int step; // 1-based
  final int total;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (onBack != null)
              GestureDetector(
                onTap: onBack,
                child: const Padding(
                  padding: EdgeInsets.only(right: AppSpacing.sm),
                  child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                ),
              ),
            Text(
              'Step $step of $total',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (var i = 1; i <= total; i++) ...[
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= step ? AppColors.teal : AppColors.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (i < total) const SizedBox(width: AppSpacing.xs),
            ],
          ],
        ),
      ],
    );
  }
}
