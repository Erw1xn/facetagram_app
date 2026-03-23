enum PostType { image, news }

class Post {
  final String? userId; // The ID of the person who created the post
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
    this.userId, // Add this
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