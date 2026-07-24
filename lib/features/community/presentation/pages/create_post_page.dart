import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safemom/core/constants/app_colors.dart';
import 'package:safemom/core/constants/app_spacing.dart';
import 'package:safemom/core/theme/app_text_styles.dart';
import 'package:safemom/core/widgets/safemom_bottom_nav.dart';
import 'package:safemom/core/widgets/widgets.dart';
import 'package:safemom/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:safemom/features/emergency/presentation/emergency_actions.dart';

import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';

/// Screen 11 — Anonymous Post / Create Post.
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _controller = TextEditingController();
  final _photoUrlController = TextEditingController();
  bool _isAnonymous = false;
  bool _prefilledDefault = false;

  static const _maxLength = 2000; // matches the real CreatePost usecase's limit
  static final _urlRegex = RegExp(r'^https?://[^\s]+$');

  @override
  void dispose() {
    _controller.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  void _toggleAnonymous(bool value) {
    setState(() => _isAnonymous = value);
    context.read<CommunityBloc>().add(DefaultAnonymousToggled(value));
  }

  bool get _hasValidPhotoUrl {
    final url = _photoUrlController.text.trim();
    return url.isNotEmpty && _urlRegex.hasMatch(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leadingWidth: 90,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppTextStyles.body
                .copyWith(fontWeight: FontWeight.bold)
                .copyWith(color: AppColors.teal),
          ),
        ),
        title: Text('New Post', style: AppTextStyles.h2),
        centerTitle: true,
      ),
      bottomNavigationBar: SafeMomBottomNav(
        currentIndex: 2,
        onTabSelected: (_) {},
        onSosPressed: () => launchEmergencySos(context),
      ),
      body: BlocConsumer<CommunityBloc, CommunityState>(
        listenWhen: (previous, current) =>
        previous.composerStatus != current.composerStatus,
        listener: (context, state) {
          if (state.composerStatus == ComposerStatus.success) {
            Navigator.pop(context);
            final pending = state.lastSubmittedPost?.isPending ?? false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  pending
                      ? "Posted — pending a quick moderator review before it's visible to others."
                      : 'Posted to the community feed.',
                ),
              ),
            );
          } else if (state.composerStatus == ComposerStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.composerError ?? 'Could not post.')),
            );
          }
        },
        builder: (context, state) {
          if (!_prefilledDefault) {
            _isAnonymous = state.defaultAnonymous;
            _prefilledDefault = true;
          }
          final isSubmitting = state.composerStatus == ComposerStatus.submitting;
          final canSubmit =
              _controller.text.trim().length >= 3 && !isSubmitting;
          final groupName = state.group?.name ?? 'your group';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _isAnonymous
                        ? const Color(0xFFFBE7DD)
                        : AppColors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isAnonymous
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: _isAnonymous
                            ? const Color(0xFFD97A52)
                            : AppColors.teal,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _isAnonymous
                              ? 'Posting as Anonymous mum.'
                              : 'Posting with your name & photo visible.',
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.groups_rounded,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: AppSpacing.sm),
                      Text('In: $groupName', style: AppTextStyles.body),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ---------- PHOTO SECTION ----------
                Text(
                  'Add a photo (optional)',
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Paste a public image URL (e.g. from Unsplash).',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: TextField(
                      controller: _photoUrlController,
                      keyboardType: TextInputType.url,
                      style: AppTextStyles.body,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'https://...',
                        icon: Icon(Icons.link_rounded,
                            color: AppColors.textSecondary),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                if (_hasValidPhotoUrl) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Image.network(
                        _photoUrlController.text.trim(),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.cardSurface,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              color: AppColors.teal,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.cardSurface,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Could not load image from this URL.',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() => _photoUrlController.clear());
                      },
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Remove photo'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.md),

                // ---------- BODY ----------
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: TextField(
                      controller: _controller,
                      maxLength: _maxLength,
                      maxLines: 8,
                      minLines: 5,
                      style: AppTextStyles.body,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText:
                        "Share a question, a win, or what you're going through...",
                        counterText: '',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_controller.text.length}/$_maxLength',
                    style: AppTextStyles.caption,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                InkWell(
                  onTap: () => _toggleAnonymous(!_isAnonymous),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Icon(
                          _isAnonymous
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: AppColors.teal,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Your name and photo will not be shown',
                            style: AppTextStyles.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Opacity(
                  opacity: canSubmit ? 1 : 0.5,
                  child: SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Post',
                      isLoading: isSubmitting,
                      onPressed: () {
                        final text = _controller.text.trim();
                        final user = context.read<AuthBloc>().state.user;
                        if (text.length < 3 || isSubmitting || user == null) {
                          return;
                        }
                        FocusScope.of(context).unfocus();

                        final rawPhotoUrl = _photoUrlController.text.trim();
                        final photoUrl = rawPhotoUrl.isEmpty
                            ? null
                            : rawPhotoUrl;

                        context.read<CommunityBloc>().add(
                          PostSubmitted(
                            authorUserId: user.userId,
                            body: text,
                            photoUrl: photoUrl,
                            isAnonymous: _isAnonymous,
                            pregnancyWeek: user.currentWeek,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}