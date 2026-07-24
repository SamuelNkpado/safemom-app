import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safemom/core/constants/app_colors.dart';
import 'package:safemom/core/constants/app_spacing.dart';
import 'package:safemom/core/router/app_routes.dart';
import 'package:safemom/core/theme/app_text_styles.dart';
import 'package:safemom/core/widgets/widgets.dart';
import 'package:safemom/features/auth/presentation/bloc/auth_bloc.dart';

import '../bloc/community_bloc.dart';
import 'package:safemom/features/emergency/presentation/emergency_actions.dart'; // TEMP — for the test button below only
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';
import '../widgets/community_status_view.dart';
import '../widgets/feed_shimmer_list.dart';
import '../widgets/post_card.dart';

enum _FeedSection { posts, photos, about }

/// Screen 10 — Community Feed.
/// Assumes CommunityBloc and AuthBloc are both already provided above this
/// widget in the tree (see main.dart wiring notes).
class CommunityFeedPage extends StatefulWidget {
  const CommunityFeedPage({super.key});

  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage> {
  _FeedSection _section = _FeedSection.posts;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  void _loadFeed() {
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      context.read<CommunityBloc>().add(FeedRequested(user.currentWeek));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: AppColors.emergencyRed,
        onPressed: () => launchEmergencySos(context),
        child: const Icon(Icons.sos_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _GroupHeader(
              section: _section,
              onSectionChanged: (s) => setState(() => _section = s),
            ),
            Expanded(child: _buildSectionBody(context)),
          ],
        ),
      ),
      bottomNavigationBar: _section == _FeedSection.posts
          ? SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Create post',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.createPost),
            ),
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildSectionBody(BuildContext context) {
    switch (_section) {
      case _FeedSection.photos:
        return BlocBuilder<CommunityBloc, CommunityState>(
          builder: (context, state) {
            final postsWithPhotos = state.posts
                .where((p) => p.photoUrl != null && p.photoUrl!.isNotEmpty)
                .toList();

            if (state.feedStatus == FeedStatus.loading ||
                state.feedStatus == FeedStatus.initial) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: FeedShimmerList(),
              );
            }

            if (postsWithPhotos.isEmpty) {
              return const CommunityStatusView(
                icon: Icons.photo_library_outlined,
                title: 'No photos yet',
                message:
                'Photos shared with posts will appear here once someone in the group adds one.',
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.xs,
                mainAxisSpacing: AppSpacing.xs,
              ),
              itemCount: postsWithPhotos.length,
              itemBuilder: (context, index) {
                final post = postsWithPhotos[index];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.communityPost,
                    arguments: post,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      post.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cardSurface,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );

      case _FeedSection.about:
        return BlocBuilder<CommunityBloc, CommunityState>(
          builder: (context, state) {
            final group = state.group;
            if (group == null) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Group information is not available yet.',
                ),
              );
            }

            final formattedCreatedAt =
                '${group.createdAt.day}/${group.createdAt.month}/${group.createdAt.year}';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.sm),
                  Text(group.description, style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.lg),
                  _AboutRow(
                    icon: Icons.groups_outlined,
                    label: 'Members',
                    value: '${group.memberCount}',
                  ),
                  _AboutRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Created',
                    value: formattedCreatedAt,
                  ),
                  if (group.locationFilter != null &&
                      group.locationFilter!.isNotEmpty)
                    _AboutRow(
                      icon: Icons.place_outlined,
                      label: 'Location',
                      value: group.locationFilter!,
                    ),
                  _AboutRow(
                    icon: group.isPrivate
                        ? Icons.lock_outline
                        : Icons.public_outlined,
                    label: 'Visibility',
                    value: group.isPrivate ? 'Private' : 'Open to all',
                  ),
                ],
              ),
            );
          },
        );

      case _FeedSection.posts:
        return BlocBuilder<CommunityBloc, CommunityState>(
          builder: (context, state) {
            if (state.groupStatus == GroupStatus.error) {
              return CommunityStatusView(
                icon: Icons.groups_outlined,
                title: 'No group yet',
                message: state.groupError ?? 'Something went wrong.',
                actionLabel: 'Retry',
                onAction: _loadFeed,
              );
            }
            switch (state.feedStatus) {
              case FeedStatus.initial:
              case FeedStatus.loading:
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: FeedShimmerList(),
                );
              case FeedStatus.error:
                return CommunityStatusView(
                  icon: Icons.wifi_off_rounded,
                  title: 'Feed unavailable',
                  message: state.feedError ?? 'Something went wrong.',
                  actionLabel: 'Retry',
                  onAction: _loadFeed,
                );
              case FeedStatus.success:
                if (state.posts.isEmpty) {
                  return const CommunityStatusView(
                    icon: Icons.forum_outlined,
                    title: 'No posts yet',
                    message:
                    'Be the first mama to share something with the group.',
                  );
                }
                final currentUserId = context
                    .read<AuthBloc>()
                    .state
                    .user
                    ?.userId;
                return RefreshIndicator(
                  color: AppColors.teal,
                  onRefresh: () async => _loadFeed(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: state.posts.length,
                    separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      return PostCard(
                        post: post,
                        isOwnPost: post.authorUserId == currentUserId,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.communityPost,
                          arguments: post,
                        ),
                      );
                    },
                  ),
                );
            }
          },
        );
    }
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AboutRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label: ',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final _FeedSection section;
  final ValueChanged<_FeedSection> onSectionChanged;

  const _GroupHeader({required this.section, required this.onSectionChanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityBloc, CommunityState>(
      buildWhen: (previous, current) => previous.group != current.group,
      builder: (context, state) {
        final group = state.group;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group?.name ?? 'Community',
                      style: AppTextStyles.h2,
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.teal.withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              if (group != null)
                Text(
                  '${group.memberCount} members',
                  style: AppTextStyles.caption,
                ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _SectionTab(
                    label: 'Posts',
                    isActive: section == _FeedSection.posts,
                    onTap: () => onSectionChanged(_FeedSection.posts),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _SectionTab(
                    label: 'Photos',
                    isActive: section == _FeedSection.photos,
                    onTap: () => onSectionChanged(_FeedSection.photos),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _SectionTab(
                    label: 'About',
                    isActive: section == _FeedSection.about,
                    onTap: () => onSectionChanged(_FeedSection.about),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SectionTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isActive ? AppColors.teal : Colors.transparent,
            border: Border.all(color: AppColors.teal),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body
                .copyWith(fontWeight: FontWeight.bold)
                .copyWith(color: isActive ? Colors.white : AppColors.teal),
          ),
        ),
      ),
    );
  }
}