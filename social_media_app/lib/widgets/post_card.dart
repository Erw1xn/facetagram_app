import 'package:flutter/material.dart';
import '../models/post_model.dart';

// --- POST CARD: A dynamic widget that handles both standard images and news-style posts ---
class PostCard extends StatefulWidget {
  final Post post;
  // ADDED: New parameters to receive YOUR current profile data
  final String currentUserName;
  final String currentUserProfilePic;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserName, // Required to show your name in comments
    required this.currentUserProfilePic, // Required to show your pic in comments
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // --- UI State Management ---
  bool _isLiked = false;
  bool _isSaved = false;
  bool _isFollowing = true;
  late int _likesCount;
  final TextEditingController _commentController = TextEditingController();

  // Mock data for the nested comment section
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
    _likesCount = int.tryParse(widget.post.likes.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

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
            child: InteractiveViewer(
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

  void _handleLikeToggle() {
    setState(() {
      _isLiked = !_isLiked;
      _isLiked ? _likesCount++ : _likesCount--;
    });
  }

  // --- FIXED: Uses dynamic user data instead of "You" and Unsplash ---
  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _comments.insert(0, {
          "user": widget.currentUserName, // Dynamically set from your profile
          "comment": _commentController.text,
          "pic": widget.currentUserProfilePic, // Dynamically set from your profile
        });
        _commentController.clear();
      });
    }
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    height: 5, width: 40,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))
                ),
                Text("${_comments.length} Comments", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
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
                // --- FIXED: Input section profile pic ---
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 10, left: 15, right: 15, top: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(widget.currentUserProfilePic), // FIXED
                      ),
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
                          setModalState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          if (widget.post.type == PostType.image) ...[
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
      ],
    );
  }

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