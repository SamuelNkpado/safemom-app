import 'package:equatable/equatable.dart';
import '../../domain/entities/community_group.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/reply.dart';

enum GroupStatus { initial, loading, success, error }
enum FeedStatus { initial, loading, success, error }
enum ComposerStatus { idle, submitting, success, error }

class CommunityState extends Equatable {
  final GroupStatus groupStatus;
  final CommunityGroup? group;
  final String? groupError;

  final FeedStatus feedStatus;
  final List<Post> posts;
  final String? feedError;

  final bool defaultAnonymous;

  final ComposerStatus composerStatus;
  final String? composerError;
  final Post? lastSubmittedPost;

  final ComposerStatus replyStatus;
  final String? replyError;
  final Map<String, List<Reply>> localRepliesByPostId;

  const CommunityState({
    this.groupStatus = GroupStatus.initial,
    this.group,
    this.groupError,
    this.feedStatus = FeedStatus.initial,
    this.posts = const [],
    this.feedError,
    this.defaultAnonymous = false,
    this.composerStatus = ComposerStatus.idle,
    this.composerError,
    this.lastSubmittedPost,
    this.replyStatus = ComposerStatus.idle,
    this.replyError,
    this.localRepliesByPostId = const {},
  });

  List<Reply> repliesFor(String postId) => localRepliesByPostId[postId] ?? const [];

  CommunityState copyWith({
    GroupStatus? groupStatus,
    CommunityGroup? group,
    String? groupError,
    FeedStatus? feedStatus,
    List<Post>? posts,
    String? feedError,
    bool? defaultAnonymous,
    ComposerStatus? composerStatus,
    String? composerError,
    Post? lastSubmittedPost,
    ComposerStatus? replyStatus,
    String? replyError,
    Map<String, List<Reply>>? localRepliesByPostId,
  }) {
    return CommunityState(
      groupStatus: groupStatus ?? this.groupStatus,
      group: group ?? this.group,
      groupError: groupError,
      feedStatus: feedStatus ?? this.feedStatus,
      posts: posts ?? this.posts,
      feedError: feedError,
      defaultAnonymous: defaultAnonymous ?? this.defaultAnonymous,
      composerStatus: composerStatus ?? this.composerStatus,
      composerError: composerError,
      lastSubmittedPost: lastSubmittedPost ?? this.lastSubmittedPost,
      replyStatus: replyStatus ?? this.replyStatus,
      replyError: replyError,
      localRepliesByPostId: localRepliesByPostId ?? this.localRepliesByPostId,
    );
  }

  @override
  List<Object?> get props => [
        groupStatus,
        group,
        groupError,
        feedStatus,
        posts,
        feedError,
        defaultAnonymous,
        composerStatus,
        composerError,
        lastSubmittedPost,
        replyStatus,
        replyError,
        localRepliesByPostId,
      ];
}
