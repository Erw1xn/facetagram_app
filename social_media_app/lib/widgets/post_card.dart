import 'package:flutter/material.dart';
import '../models/post_model.dart';

// --- POST CARD: A dynamic widget that handles both standard images and news-style posts ---
class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // --- UI State Management ---
  // Tracks whether the current user has liked the post
  bool _isLiked = false;
  // Tracks whether the post is saved/bookmarked
  bool _isSaved = false;
  // Tracks the follow status for the post author
  bool _isFollowing = true;
  // Numerical storage for likes to allow for real-time increment/decrement
  late int _likesCount;
  // Controller to handle text input in the comment bottom sheet
  final TextEditingController _commentController = TextEditingController();

  // Mock data for the nested comment section: Represents a list of existing comments
  final List<Map<String, String>> _comments = [
    {
      "user": "alex_dev",
      "comment": "This looks amazing! What stack are you using? 🔥",
      "pic": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150"
    },
    {
      "user": "sarah_explore",
      "comment": "Nature is truly healing. Great shot!",
      "pic": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150"
    },
    {
      "user": "mike_ross",
      "comment": "I need to visit this place soon. 🌲",
      "pic": "https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150"
    },
  ];

  @override
  void initState() {
    super.initState();
    // Regex logic: Extracts only the digits from the post's 'likes' string to enable math operations
    _likesCount = int.tryParse(widget.post.likes.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  // Navigation Logic: Opens the image in a dedicated full-screen scaffold with zoom capabilities
  // Uses InteractiveViewer to enable pinch-to-zoom functionality
  void _viewFullImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer( // Allows users to pinch-to-zoom on the photo
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Toggles like state and updates the numerical counter locally
  // Triggers a UI rebuild to reflect the new like count and icon color
  void _handleLikeToggle() {
    setState(() {
      _isLiked = !_isLiked;
      _isLiked ? _likesCount++ : _likesCount--;
    });
  }

  // Local State Update: Inserts a new comment into the top of the list
  // Clears the text field after successful submission
  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _comments.insert(0, {
          "user": "You",
          "comment": _commentController.text,
          "pic": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150",
        });
        _commentController.clear();
      });
    }
  }

  // UI Helper: Builds the interactive comment section bottom sheet
  // Uses DraggableScrollableSheet to allow the user to pull the comments up or down
  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to move when the keyboard opens
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (context, scrollController) => Column(
              children: [
                // Top handle bar for the bottom sheet
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    height: 5, width: 40,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))
                ),
                Text("${_comments.length} Comments", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                // List of comments that scrolls independently within the sheet
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final item = _comments[index];
                      return ListTile(
                        leading: CircleAvatar(radius: 16, backgroundImage: NetworkImage(item["pic"]!)),
                        title: Text(item["user"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(item["comment"]!, style: const TextStyle(color: Colors.black87)),
                      );
                    },
                  ),
                ),
                // Comment Input Area: Positioned at the bottom, adjusted for keyboard height
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 10, left: 15, right: 15, top: 10),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150')),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(hintText: "Add a comment...", border: InputBorder.none),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _addComment();
                          setModalState(() {}); // Forces the modal to refresh after adding a comment
                        },
                        child: const Text("Post", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Main build method: Orchestrates the high-level layout of the PostCard
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Displays user info and the conditional Follow button
          ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(widget.post.profileUrl)),
            title: Text(widget.post.username, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.post.type == PostType.news ? "Page name • Sponsored" : widget.post.handle),
            trailing: widget.post.type == PostType.image
                ? TextButton(
              onPressed: () {
                setState(() => _isFollowing = !_isFollowing);
              },
              child: Text(
                _isFollowing ? "Following" : "Follow",
                style: TextStyle(
                  color: _isFollowing ? Colors.grey : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : null,
          ),

          // --- CONDITIONAL CONTENT: Determines layout based on whether post is an Image or News Link ---
          if (widget.post.type == PostType.image) ...[
            // Rendering logic for standard image posts
            if (widget.post.mediaUrl != null)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _viewFullImage(context, widget.post.mediaUrl!),
                  child: Image.network(widget.post.mediaUrl!, fit: BoxFit.cover, width: double.infinity),
                ),
              ),
            _buildImageActions(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(widget.post.content),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "❤️ $_likesCount   💬 ${_comments.length} Comments",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ] else ...[
            // Rendering logic for News-style posts
            _buildNewsBox(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "💙❤️ $_likesCount Likes • ${_comments.length} Comments",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const Divider(height: 1),
            _buildNewsActions(context),
          ],
        ],
      ),
    );
  }

  // --- ACTIONS REMOVED SHARE BUTTON ---
  // UI Helper: Builds the action buttons (Like, Comment, Save) for Image posts
  Widget _buildImageActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? Colors.red : Colors.black, size: 28),
            onPressed: _handleLikeToggle,
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, size: 26),
            onPressed: () => _showComments(context),
          ),
          // SHARE BUTTON REMOVED per user request
          const Spacer(),
          IconButton(
            icon: Icon(
                _isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.black,
                size: 28
            ),
            onPressed: () => setState(() => _isSaved = !_isSaved),
          ),
        ],
      ),
    );
  }

  // UI Helper: Builds the action row (Like and Comment) for News-style posts
  Widget _buildNewsActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _actionBtn(
            _isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
            "Like",
            _isLiked ? Colors.blue : Colors.grey[700]!,
            _handleLikeToggle
        ),
        _actionBtn(Icons.chat_bubble_outline, "Comment", Colors.grey[700]!, () => _showComments(context)),
        // SHARE BUTTON REMOVED per user request
      ],
    );
  }

  // Button Template: Returns a stylized button with an icon and label for news actions
  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // UI Helper: Builds the stylized container for the News Link, including image and metadata
  Widget _buildNewsBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.post.mediaUrl != null)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _viewFullImage(context, widget.post.mediaUrl!),
                child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(widget.post.mediaUrl!, fit: BoxFit.cover)
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("NEWS LINK", style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.1)),
                const SizedBox(height: 4),
                Text(widget.post.newsTitle ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(widget.post.newsSubtext ?? "", maxLines: 2, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}