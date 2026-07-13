import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Home tab. Placeholder scaffold — owner (partner) replaces the body with the
/// weekly-tip hero, "Today's check-in", and saved tips per the Figma.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Karibu, Mama', style: AppTextStyles.h1)),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.pageTop,
        ),
        child: Text('Home — build me', style: AppTextStyles.body),
      ),
    );
  }
}
