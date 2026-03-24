enum PostType { image, news, video }

class Post {
  final String? userId; // Make sure this is here!
  final String username;
  final String handle;
  final String profileUrl;
  final String content;
  final String? mediaUrl;
  final PostType type;
  final String likes;
  final String comments;
  final String? newsTitle;
  final String? newsSubtext;

  Post({
    this.userId,
    required this.username,
    required this.handle,
    required this.profileUrl,
    required this.content,
    this.mediaUrl,
    required this.type,
    required this.likes,
    required this.comments,
    this.newsTitle,
    this.newsSubtext,
  });
}