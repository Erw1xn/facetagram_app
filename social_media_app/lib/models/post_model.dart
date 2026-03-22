// Defines available post formats: a standard image post or a news link
enum PostType { image, news }

class Post {
  // User identity fields
  final String username;
  final String handle;
  final String profileUrl;

  // Main post body text
  final String content;

  // Optional media (image/video) and the logic switch for post type
  final String? mediaUrl;
  final PostType type;

  // Optional fields used specifically when PostType is 'news'
  final String? newsTitle;
  final String? newsSubtext;

  // Social engagement metrics (stored as Strings for easy display)
  final String likes;
  final String comments;

  // Constructor with named parameters
  Post({
    required this.username,
    required this.handle,
    required this.profileUrl,
    required this.content,
    this.mediaUrl,
    this.type = PostType.image, // Defaults to image type
    this.newsTitle,
    this.newsSubtext,
    this.likes = "0", // Defaults to zero likes
    this.comments = "0", // Defaults to zero comments
  });
}