import 'package:flutter/material.dart';
import 'package:safemom/core/constants/app_colors.dart';
import 'package:safemom/core/constants/app_spacing.dart';
import 'package:safemom/core/theme/app_text_styles.dart';
import 'package:safemom/core/widgets/widgets.dart';

import '../../domain/entities/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool isOwnPost;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.isOwnPost,
    required this.onTap,
  });

  String get _displayName {
    if (post.isAnonymous) return 'Anonymous mum';
    if (isOwnPost) return 'You';
    return 'A member';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      post.isAnonymous ? const Color(0xFFF0A98A) : AppColors.teal,
                  child: Text(
                    _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: _displayName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                        if (post.pregnancyWeekAtPost != null)
                          TextSpan(
                            text: '  ·  Week ${post.pregnancyWeekAtPost}',
                            style: AppTextStyles.caption,
                          ),
                        TextSpan(
                          text: '  ·  ${_timeAgo(post.createdAt)}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ),
                if (post.isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Pending review', style: TextStyle(fontSize: 10)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(post.body, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.favorite_border_rounded, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${post.likesCount} ${post.likesCount == 1 ? 'like' : 'likes'}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(width: AppSpacing.lg),
                Icon(Icons.mode_comment_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${post.repliesCount} ${post.repliesCount == 1 ? 'reply' : 'replies'}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 2) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}
