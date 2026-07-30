import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safemom/core/constants/app_colors.dart';
import 'package:safemom/core/constants/app_spacing.dart';
import 'package:safemom/core/theme/app_text_styles.dart';
import 'package:safemom/features/auth/presentation/bloc/auth_bloc.dart';

import '../../domain/entities/post.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';
import '../widgets/post_card.dart';
import '../widgets/reply_tile.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _replyController = TextEditingController();
  bool _replyAnonymous = false;

  // Local copy of the post body so an edit shows on this page immediately.
  late String _body;

  @override
  void initState() {
    super.initState();
    _body = widget.post.body;
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _openEditDialog(BuildContext context, String currentUserId) {
    final controller = TextEditingController(text: _body);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: Text('Edit post', style: AppTextStyles.h3),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          minLines: 1,
          style: AppTextStyles.body,
          decoration: const InputDecoration(
            hintText: 'Update your post...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTextStyles.button),
          ),
          TextButton(
            onPressed: () {
              final newBody = controller.text.trim();
              if (newBody.isEmpty) return;
              context.read<CommunityBloc>().add(
                PostEdited(
                  postId: widget.post.postId,
                  authorUserId: currentUserId,
                  body: newBody,
                ),
              );
              // Update this page immediately.
              setState(() => _body = newBody);
              Navigator.pop(dialogContext);
            },
            child: Text(
              'Save',
              style: AppTextStyles.button.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String currentUserId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: Text('Delete post?', style: AppTextStyles.h3),
        content: Text(
          'This permanently removes your post. This cannot be undone.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTextStyles.button),
          ),
          TextButton(
            onPressed: () {
              context.read<CommunityBloc>().add(
                PostDeleted(
                  postId: widget.post.postId,
                  authorUserId: currentUserId,
                ),
              );
              Navigator.pop(dialogContext); // close the confirm dialog
              Navigator.pop(context); // leave the detail page, back to feed
            },
            child: Text(
              'Delete',
              style: AppTextStyles.button.copyWith(
                color: AppColors.emergencyRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthBloc>().state.user?.userId;
    final isOwnPost = widget.post.authorUserId == currentUserId;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text('Post', style: AppTextStyles.h2),
      ),
      body: BlocConsumer<CommunityBloc, CommunityState>(
        listenWhen: (previous, current) =>
        previous.replyStatus != current.replyStatus,
        listener: (context, state) {
          if (state.replyStatus == ComposerStatus.success) {
            _replyController.clear();
          } else if (state.replyStatus == ComposerStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.replyError ?? 'Reply failed.')),
            );
          }
        },
        builder: (context, state) {
          final localReplies = state.repliesFor(widget.post.postId);
          final isSendingReply = state.replyStatus == ComposerStatus.submitting;

          // Render with the possibly-edited body.
          final displayedPost = widget.post.copyWith(body: _body);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    PostCard(
                      post: displayedPost,
                      isOwnPost: isOwnPost,
                      onTap: () {},
                      onEdit: isOwnPost && currentUserId != null
                          ? () => _openEditDialog(context, currentUserId)
                          : null,
                      onDelete: isOwnPost && currentUserId != null
                          ? () => _confirmDelete(context, currentUserId)
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Replies (${widget.post.repliesCount + localReplies.length})',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (widget.post.repliesCount == 0 && localReplies.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        child: Text(
                          'No replies yet. Be the first to respond.',
                          style: AppTextStyles.caption,
                        ),
                      )
                    else if (widget.post.repliesCount > localReplies.length)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          "This post has ${widget.post.repliesCount} repl${widget.post.repliesCount == 1 ? 'y' : 'ies'} "
                              "that can't be listed yet — showing replies sent this session below.",
                          style: AppTextStyles.caption,
                        ),
                      ),
                    for (final reply in localReplies)
                      ReplyTile(
                        reply: reply,
                        isOwnReply: reply.authorUserId == currentUserId,
                      ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _replyAnonymous
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: _replyAnonymous ? Colors.grey : AppColors.teal,
                        ),
                        tooltip: _replyAnonymous
                            ? 'Replying anonymously'
                            : 'Replying with your name',
                        onPressed: () =>
                            setState(() => _replyAnonymous = !_replyAnonymous),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          style: AppTextStyles.body,
                          decoration: const InputDecoration(
                            hintText: 'Write a reply...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      isSendingReply
                          ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                          : IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: AppColors.teal,
                        ),
                        onPressed: () {
                          final text = _replyController.text.trim();
                          final user = context
                              .read<AuthBloc>()
                              .state
                              .user;
                          if (text.isEmpty || user == null) return;
                          context.read<CommunityBloc>().add(
                            ReplySubmitted(
                              postId: widget.post.postId,
                              authorUserId: user.userId,
                              body: text,
                              isAnonymous: _replyAnonymous,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}