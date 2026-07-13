import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Profile tab. Placeholder — owner (partner) replaces with appointments,
/// clinic info and settings (theme/language) per the Figma.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile', style: AppTextStyles.h2)),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.pageTop,
        ),
        child: Text('Profile — build me', style: AppTextStyles.body),
      ),
    );
  }
}
