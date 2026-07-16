import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Symptoms tab. Placeholder — owner (partner) replaces with the symptom log
/// list and the danger-check flow per the Figma.
class SymptomsPage extends StatelessWidget {
  const SymptomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Symptoms', style: AppTextStyles.h2)),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.pageTop,
        ),
        child: Text('Symptoms — build me', style: AppTextStyles.body),
      ),
    );
  }
}
