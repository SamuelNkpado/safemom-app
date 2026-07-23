import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/reply.dart';
import '../../domain/usecases/create_post.dart';
import '../../domain/usecases/create_reply.dart';
import '../../domain/usecases/get_available_groups.dart';
import '../../domain/usecases/get_group_posts.dart';
import 'community_event.dart';
import 'community_state.dart';

const _kDefaultAnonymousPrefKey = 'community.defaultAnonymous';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final GetAvailableGroups getAvailableGroups;
  final GetGroupPosts getGroupPosts;
  final CreatePost createPost;
  final CreateReply createReply;

  CommunityBloc({
    required this.getAvailableGroups,
    required this.getGroupPosts,
    required this.createPost,
    required this.createReply,
  }) : super(const CommunityState()) {
    on<FeedRequested>(_onFeedRequested);
    on<DefaultAnonymousToggled>(_onDefaultAnonymousToggled);
    on<PostSubmitted>(_onPostSubmitted);
    on<ReplySubmitted>(_onReplySubmitted);
    on<_PreferencesLoaded>((event, emit) => emit(state.copyWith(defaultAnonymous: event.value)));
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAnonymous = prefs.getBool(_kDefaultAnonymousPrefKey) ?? false;
    if (!isClosed) add(_PreferencesLoaded(savedAnonymous));
  }

  Future<void> _onFeedRequested(FeedRequested event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(groupStatus: GroupStatus.loading, feedStatus: FeedStatus.loading));
    try {
      final groups = await getAvailableGroups(pregnancyWeek: event.pregnancyWeek);
      if (groups.isEmpty) {
        emit(state.copyWith(
          groupStatus: GroupStatus.error,
          groupError: 'No community groups are set up yet.',
          feedStatus: FeedStatus.error,
        ));
        return;
      }
      final group = groups.first;
      emit(state.copyWith(groupStatus: GroupStatus.success, group: group));

      final posts = await getGroupPosts(groupId: group.groupId);
      emit(state.copyWith(feedStatus: FeedStatus.success, posts: posts));
    } on ArgumentError catch (e) {
      emit(state.copyWith(
        groupStatus: GroupStatus.error,
        groupError: e.message.toString(),
        feedStatus: FeedStatus.error,
      ));
    } catch (_) {
      emit(state.copyWith(
        groupStatus: GroupStatus.error,
        groupError: 'Could not load the community feed.',
        feedStatus: FeedStatus.error,
      ));
    }
  }

  Future<void> _onDefaultAnonymousToggled(DefaultAnonymousToggled event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(defaultAnonymous: event.value));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDefaultAnonymousPrefKey, event.value);
  }

  Future<void> _onPostSubmitted(PostSubmitted event, Emitter<CommunityState> emit) async {
    final group = state.group;
    if (group == null) {
      emit(state.copyWith(
        composerStatus: ComposerStatus.error,
        composerError: 'No group loaded yet — go back and reopen the feed.',
      ));
      return;
    }
    emit(state.copyWith(composerStatus: ComposerStatus.submitting));
    try {
      final post = await createPost(
        groupId: group.groupId,
        authorUserId: event.authorUserId,
        body: event.body,
        isAnonymous: event.isAnonymous,
        pregnancyWeekAtPost: event.pregnancyWeek,
      );
      final updatedPosts = post.isPublished ? [post, ...state.posts] : state.posts;
      emit(state.copyWith(
        composerStatus: ComposerStatus.success,
        lastSubmittedPost: post,
        posts: updatedPosts,
      ));
    } on ArgumentError catch (e) {
      emit(state.copyWith(composerStatus: ComposerStatus.error, composerError: e.message.toString()));
    } catch (_) {
      emit(state.copyWith(
        composerStatus: ComposerStatus.error,
        composerError: 'Could not post right now. Check your connection and try again.',
      ));
    }
  }

  Future<void> _onReplySubmitted(ReplySubmitted event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(replyStatus: ComposerStatus.submitting));
    try {
      final reply = await createReply(
        postId: event.postId,
        authorUserId: event.authorUserId,
        body: event.body,
        isAnonymous: event.isAnonymous,
      );
      final updated = Map<String, List<Reply>>.from(state.localRepliesByPostId);
      updated[event.postId] = [...state.repliesFor(event.postId), reply];
      emit(state.copyWith(replyStatus: ComposerStatus.success, localRepliesByPostId: updated));
    } on ArgumentError catch (e) {
      emit(state.copyWith(replyStatus: ComposerStatus.error, replyError: e.message.toString()));
    } catch (_) {
      emit(state.copyWith(replyStatus: ComposerStatus.error, replyError: 'Reply did not send. Try again.'));
    }
  }
}

class _PreferencesLoaded extends CommunityEvent {
  final bool value;
  const _PreferencesLoaded(this.value);
  @override
  List<Object?> get props => [value];
}
