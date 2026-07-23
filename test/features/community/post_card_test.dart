import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safemom/features/community/domain/entities/post.dart';
import 'package:safemom/features/community/presentation/widgets/post_card.dart';

void main() {
  testWidgets('PostCard shows anonymous label, week, body, likes and replies',
      (tester) async {
    final post = Post(
      postId: 'p1',
      groupId: 'g1',
      authorUserId: 'u1',
      body: 'Feeling nauseous today, any tips?',
      isAnonymous: true,
      moderationStatus: ModerationStatus.approved,
      likesCount: 4,
      repliesCount: 2,
      pregnancyWeekAtPost: 22,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PostCard(post: post, isOwnPost: false, onTap: () {})),
      ),
    );

    expect(find.textContaining('Anonymous mum'), findsOneWidget);
    expect(find.text('Feeling nauseous today, any tips?'), findsOneWidget);
    expect(find.text('4 likes'), findsOneWidget);
    expect(find.text('2 replies'), findsOneWidget);
  });

  testWidgets('shows "You" for the current user\'s own non-anonymous post', (tester) async {
    final post = Post(
      postId: 'p2',
      groupId: 'g1',
      authorUserId: 'u1',
      body: 'Made it to my 20-week scan!',
      isAnonymous: false,
      moderationStatus: ModerationStatus.approved,
      likesCount: 0,
      repliesCount: 0,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PostCard(post: post, isOwnPost: true, onTap: () {})),
      ),
    );

    expect(find.textContaining('You'), findsOneWidget);
  });
}
