import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../theme/app_text_styles.dart';

/// Red SOS / emergency pill button (56px). The only place emergencyRed is
/// allowed. Ships with an icon by default.
class EmergencyButton extends StatelessWidget {
  const EmergencyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon = Icons.warning_amber_rounded,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emergencyRed,
          disabledBackgroundColor: AppColors.emergencyRed.withValues(alpha: 0.5),
          foregroundColor: AppColors.textOnColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: AppColors.textOnColor),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: AppTextStyles.button.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
