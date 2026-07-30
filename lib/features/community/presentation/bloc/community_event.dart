import 'package:equatable/equatable.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();
  @override
  List<Object?> get props => [];
}

class FeedRequested extends CommunityEvent {
  final int pregnancyWeek;
  const FeedRequested(this.pregnancyWeek);
  @override
  List<Object?> get props => [pregnancyWeek];
}

class DefaultAnonymousToggled extends CommunityEvent {
  final bool value;
  const DefaultAnonymousToggled(this.value);
  @override
  List<Object?> get props => [value];
}

class PostSubmitted extends CommunityEvent {
  final String authorUserId;
  final String body;
  final bool isAnonymous;
  final int pregnancyWeek;
  final String? photoUrl;

  const PostSubmitted({
    required this.authorUserId,
    required this.body,
    required this.isAnonymous,
    required this.pregnancyWeek,
    this.photoUrl,
  });

  @override
  List<Object?> get props =>
      [authorUserId, body, isAnonymous, pregnancyWeek, photoUrl];
}

class PostEdited extends CommunityEvent {
  final String postId;
  final String authorUserId;
  final String body;

  const PostEdited({
    required this.postId,
    required this.authorUserId,
    required this.body,
  });

  @override
  List<Object?> get props => [postId, authorUserId, body];
}

class PostDeleted extends CommunityEvent {
  final String postId;
  final String authorUserId;

  const PostDeleted({
    required this.postId,
    required this.authorUserId,
  });

  @override
  List<Object?> get props => [postId, authorUserId];
}

class ReplySubmitted extends CommunityEvent {
  final String postId;
  final String authorUserId;
  final String body;
  final bool isAnonymous;
  const ReplySubmitted({
    required this.postId,
    required this.authorUserId,
    required this.body,
    required this.isAnonymous,
  });
  @override
  List<Object?> get props => [postId, authorUserId, body, isAnonymous];
}