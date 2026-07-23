import 'package:flutter/material.dart';
import 'package:safemom/core/constants/app_colors.dart';
import 'package:safemom/core/constants/app_spacing.dart';
import 'package:safemom/core/theme/app_text_styles.dart';

import '../../domain/entities/reply.dart';

class ReplyTile extends StatelessWidget {
  final Reply reply;
  final bool isOwnReply;
  const ReplyTile({super.key, required this.reply, required this.isOwnReply});

  String get _displayName {
    if (reply.isAnonymous) return 'Anonymous mum';
    if (isOwnReply) return 'You';
    return 'A member';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: reply.isAnonymous
                ? Colors.grey.withValues(alpha: 0.15)
                : AppColors.teal.withValues(alpha: 0.15),
            child: Icon(
              reply.isAnonymous ? Icons.visibility_off_rounded : Icons.person_rounded,
              size: 14,
              color: reply.isAnonymous ? Colors.grey : AppColors.teal,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_displayName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(reply.body, style: AppTextStyles.body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
