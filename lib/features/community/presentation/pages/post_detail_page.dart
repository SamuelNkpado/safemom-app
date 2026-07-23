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

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthBloc>().state.user?.userId;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text('Post', style: AppTextStyles.h2),
      ),
      body: BlocConsumer<CommunityBloc, CommunityState>(
        listenWhen: (previous, current) => previous.replyStatus != current.replyStatus,
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

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    PostCard(
                      post: widget.post,
                      isOwnPost: widget.post.authorUserId == currentUserId,
                      onTap: () {},
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Replies (${widget.post.repliesCount + localReplies.length})',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (widget.post.repliesCount == 0 && localReplies.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
                      ReplyTile(reply: reply, isOwnReply: reply.authorUserId == currentUserId),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _replyAnonymous ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: _replyAnonymous ? Colors.grey : AppColors.teal,
                        ),
                        tooltip: _replyAnonymous ? 'Replying anonymously' : 'Replying with your name',
                        onPressed: () => setState(() => _replyAnonymous = !_replyAnonymous),
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
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send_rounded, color: AppColors.teal),
                              onPressed: () {
                                final text = _replyController.text.trim();
                                final user = context.read<AuthBloc>().state.user;
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
