import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Community tab. Placeholder — owner (partner) replaces with the groups list,
/// posts feed, post detail and create-post flow per the Figma.
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Community', style: AppTextStyles.h2)),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.pageTop,
        ),
        child: Text('Community — build me', style: AppTextStyles.body),
      ),
    );
  }
}
