import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safemom/features/community/domain/entities/community_group.dart';
import 'package:safemom/features/community/domain/entities/post.dart';
import 'package:safemom/features/community/domain/entities/reply.dart';
import 'package:safemom/features/community/domain/repositories/community_repository.dart';
import 'package:safemom/features/community/domain/usecases/create_post.dart';
import 'package:safemom/features/community/domain/usecases/create_reply.dart';
import 'package:safemom/features/community/domain/usecases/get_available_groups.dart';
import 'package:safemom/features/community/domain/usecases/get_group_posts.dart';
import 'package:safemom/features/community/presentation/bloc/community_bloc.dart';
import 'package:safemom/features/community/presentation/bloc/community_event.dart';
import 'package:safemom/features/community/presentation/bloc/community_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCommunityRepository extends Mock implements CommunityRepository {}

void main() {
  late MockCommunityRepository repository;
  late CommunityBloc bloc;

  // Named testGroup, not "group" — "group" collides with flutter_test's own
  // top-level group() function used below, which caused 3 real errors.
  final testGroup = CommunityGroup(
    groupId: 'g1',
    name: '2nd Trimester Moms',
    description: 'A space to share.',
    pregnancyStageFilter: PregnancyStageFilter.secondTrimester,
    locationFilter: null,
    memberCount: 1247,
    createdAt: DateTime(2026, 1, 1),
    isPrivate: false,
  );

  final post = Post(
    postId: 'p1',
    groupId: 'g1',
    authorUserId: 'u1',
    body: 'Hello mamas',
    isAnonymous: false,
    moderationStatus: ModerationStatus.approved,
    likesCount: 0,
    repliesCount: 0,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = MockCommunityRepository();
    bloc = CommunityBloc(
      getAvailableGroups: GetAvailableGroups(repository),
      getGroupPosts: GetGroupPosts(repository),
      createPost: CreatePost(repository),
      createReply: CreateReply(repository),
    );
  });

  tearDown(() => bloc.close());

  group('FeedRequested', () {
    blocTest<CommunityBloc, CommunityState>(
      'emits group then feed success when both fetches succeed',
      build: () {
        when(() => repository.getAvailableGroups(
              pregnancyWeek: any(named: 'pregnancyWeek'),
              locationHint: any(named: 'locationHint'),
            )).thenAnswer((_) async => [testGroup]);
        when(() => repository.getGroupPosts(
              groupId: any(named: 'groupId'),
              limit: any(named: 'limit'),
              before: any(named: 'before'),
            )).thenAnswer((_) async => [post]);
        return bloc;
      },
      act: (bloc) => bloc.add(const FeedRequested(22)),
      expect: () => [
        predicate<CommunityState>((s) => s.groupStatus == GroupStatus.loading),
        predicate<CommunityState>((s) => s.groupStatus == GroupStatus.success && s.group == testGroup),
        predicate<CommunityState>((s) => s.feedStatus == FeedStatus.success && s.posts.length == 1),
      ],
    );

    blocTest<CommunityBloc, CommunityState>(
      'emits an error state when no groups are available',
      build: () {
        when(() => repository.getAvailableGroups(
              pregnancyWeek: any(named: 'pregnancyWeek'),
              locationHint: any(named: 'locationHint'),
            )).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(const FeedRequested(22)),
      expect: () => [
        predicate<CommunityState>((s) => s.groupStatus == GroupStatus.loading),
        predicate<CommunityState>((s) => s.groupStatus == GroupStatus.error && s.groupError != null),
      ],
    );
  });

  group('PostSubmitted', () {
    blocTest<CommunityBloc, CommunityState>(
      'prepends the new post to the feed on success',
      build: () {
        when(() => repository.createPost(
              groupId: any(named: 'groupId'),
              authorUserId: any(named: 'authorUserId'),
              body: any(named: 'body'),
              photoUrl: any(named: 'photoUrl'),
              isAnonymous: any(named: 'isAnonymous'),
              pregnancyWeekAtPost: any(named: 'pregnancyWeekAtPost'),
            )).thenAnswer((_) async => post);
        return bloc;
      },
      seed: () => CommunityState(groupStatus: GroupStatus.success, group: testGroup),
      act: (bloc) => bloc.add(const PostSubmitted(
        authorUserId: 'u1',
        body: 'Hello mamas',
        isAnonymous: false,
        pregnancyWeek: 22,
      )),
      expect: () => [
        predicate<CommunityState>((s) => s.composerStatus == ComposerStatus.submitting),
        predicate<CommunityState>(
            (s) => s.composerStatus == ComposerStatus.success && s.posts.contains(post)),
      ],
    );

    blocTest<CommunityBloc, CommunityState>(
      'errors immediately if no group is loaded yet',
      build: () => bloc,
      act: (bloc) => bloc.add(const PostSubmitted(
        authorUserId: 'u1',
        body: 'Hello mamas',
        isAnonymous: false,
        pregnancyWeek: 22,
      )),
      expect: () => [
        predicate<CommunityState>(
            (s) => s.composerStatus == ComposerStatus.error && s.composerError != null),
      ],
    );
  });

  group('ReplySubmitted', () {
    blocTest<CommunityBloc, CommunityState>(
      'stores the new reply locally for that post on success',
      build: () {
        when(() => repository.createReply(
              postId: any(named: 'postId'),
              authorUserId: any(named: 'authorUserId'),
              body: any(named: 'body'),
              isAnonymous: any(named: 'isAnonymous'),
            )).thenAnswer((_) async => Reply(
              replyId: 'r1',
              postId: 'p1',
              authorUserId: 'u1',
              body: 'So relatable!',
              createdAt: DateTime(2026, 1, 1),
            ));
        return bloc;
      },
      act: (bloc) => bloc.add(const ReplySubmitted(
        postId: 'p1',
        authorUserId: 'u1',
        body: 'So relatable!',
        isAnonymous: false,
      )),
      expect: () => [
        predicate<CommunityState>((s) => s.replyStatus == ComposerStatus.submitting),
        predicate<CommunityState>(
            (s) => s.replyStatus == ComposerStatus.success && s.repliesFor('p1').length == 1),
      ],
    );
  });
}
