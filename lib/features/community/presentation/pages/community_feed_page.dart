import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safemom/core/constants/app_colors.dart';
import 'package:safemom/core/constants/app_spacing.dart';
import 'package:safemom/core/router/app_routes.dart';
import 'package:safemom/core/theme/app_text_styles.dart';
import 'package:safemom/core/widgets/safemom_bottom_nav.dart';
import 'package:safemom/core/widgets/widgets.dart';
import 'package:safemom/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:safemom/features/emergency/presentation/emergency_actions.dart';

import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';
import '../widgets/community_status_view.dart';
import '../widgets/feed_shimmer_list.dart';
import '../widgets/post_card.dart';

enum _FeedSection { posts, photos, about }

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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_section == _FeedSection.posts)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Create post',
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.createPost),
                ),
              ),
            ),
          SafeMomBottomNav(
            currentIndex: 2,
            onTabSelected: (_) {},
            onSosPressed: () => launchEmergencySos(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionBody(BuildContext context) {
    switch (_section) {
      case _FeedSection.photos:
        return const CommunityStatusView(
          icon: Icons.photo_library_outlined,
          title: 'Photos',
          message: 'Photo sharing is coming soon.',
        );
      case _FeedSection.about:
        return BlocBuilder<CommunityBloc, CommunityState>(
          builder: (context, state) => Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              state.group?.description ?? 'A space to share questions, wins, and support.',
              style: AppTextStyles.body,
            ),
          ),
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
                    message: 'Be the first mama to share something with the group.',
                  );
                }
                final currentUserId = context.read<AuthBloc>().state.user?.userId;
                return RefreshIndicator(
                  color: AppColors.teal,
                  onRefresh: () async => _loadFeed(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: state.posts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
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
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(group?.name ?? 'Community', style: AppTextStyles.h2)),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.teal.withValues(alpha: 0.15),
                    child: const Icon(Icons.groups_rounded, color: AppColors.teal),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              if (group != null)
                Text('${group.memberCount} members', style: AppTextStyles.caption),
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

  const _SectionTab({required this.label, required this.isActive, required this.onTap});

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
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold).copyWith(
              color: isActive ? Colors.white : AppColors.teal,
            ),
          ),
        ),
      ),
    );
  }
}
