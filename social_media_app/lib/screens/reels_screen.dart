import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// --- REELS SCREEN: The main container for the vertical video feed ---
class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data: A list of maps containing video URLs and metadata
    final List<Map<String, String>> reelData = [
      {
        'video': 'https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-large.mp4',
        'user': '@nature_lover',
        'profile': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
        'caption': 'Spring is finally here! 🌼 #nature'
      },
      {
        'video': 'https://assets.mixkit.co/videos/preview/mixkit-mother-with-her-little-daughter-eating-a-marshmallow-42221-large.mp4',
        'user': '@family_moments',
        'profile': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        'caption': 'Sweet moments with my little one. 🍬'
      },
      {
        'video': 'https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-lighting-in-the-middle-of-the-night-34644-large.mp4',
        'user': '@neon_vibes',
        'profile': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        'caption': 'Night city lights. 🌃 #neon #aesthetic'
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black, // Dark background for cinematic video feel
      body: Stack(
        children: [
          // 1. REELS VIDEO FEED: Uses a vertical PageView to simulate the "swipe up" behavior
          PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: reelData.length,
            itemBuilder: (context, index) {
              return ReelItem(
                videoUrl: reelData[index]['video']!,
                username: reelData[index]['user']!,
                profileUrl: reelData[index]['profile']!,
                caption: reelData[index]['caption']!,
              );
            },
          ),

          // 2. TOP OVERLAY (Reels Title): Positioned relative to the safe area (top padding)
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            child: const Text(
              'Reels',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(blurRadius: 10.0, color: Colors.black54, offset: Offset(0, 2)),
                ],
              ),
            ),
          ),

          // 3. TOP RIGHT ICON: Camera icon for creating new reels
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

// --- REEL ITEM: Manages individual video state and interactions ---
class ReelItem extends StatefulWidget {
  final String videoUrl;
  final String username;
  final String profileUrl;
  final String caption;

  const ReelItem({
    super.key,
    required this.videoUrl,
    required this.username,
    required this.profileUrl,
    required this.caption,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  // Interaction States
  bool _isLiked = false;
  bool _isFollowing = false;
  bool _isSaved = false;
  int _likesCount = 1200;
  final TextEditingController _commentController = TextEditingController();

  // Local Comment Store
  final List<Map<String, String>> _comments = [
    {"user": "alex_dev", "comment": "This is fire! 🔥", "pic": "https://i.pravatar.cc/150?u=9"},
    {"user": "travel_pro", "comment": "Great edit! 🎬", "pic": "https://i.pravatar.cc/150?u=12"},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the video controller with the network URL
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.setLooping(true); // Loop video infinitely
          _controller.play(); // Auto-play when ready
        });
      });
  }

  @override
  void dispose() {
    // CRITICAL: Clean up controllers to prevent memory leaks
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // Toggle Logic Helpers
  void _toggleLike() => setState(() {
    _isLiked = !_isLiked;
    _isLiked ? _likesCount++ : _likesCount--;
  });

  void _toggleFollow() => setState(() => _isFollowing = !_isFollowing);

  void _toggleSave() => setState(() => _isSaved = !_isSaved);

  // UI Helper: Shows a share prompt from the bottom
  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Icon(Icons.share_outlined, size: 40, color: Colors.blue),
            const SizedBox(height: 15),
            const Text("Share with others", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Share to others", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI Helper: Shows the comments list with a nested stateful input field
  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Necessary to push content up when keyboard appears
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          builder: (context, scrollController) => Column(
            children: [
              Container(margin: const EdgeInsets.symmetric(vertical: 10), height: 5, width: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              Text("${_comments.length} Comments", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _comments.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(_comments[index]['pic']!)),
                    title: Text(_comments[index]['user']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(_comments[index]['comment']!),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 10, left: 15, right: 15, top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(hintText: "Add comment...", border: InputBorder.none),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_commentController.text.isNotEmpty) {
                          setState(() {
                            // Update main widget state
                            _comments.insert(0, {"user": "You", "comment": _commentController.text, "pic": "https://i.pravatar.cc/150?u=me"});
                            _commentController.clear();
                          });
                          setModalState(() {}); // Force bottom sheet rebuild
                        }
                      },
                      child: const Text("Post", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background: The actual Video Player
        Positioned.fill(
          child: _isInitialized
              ? GestureDetector(
            onTap: () => _controller.value.isPlaying ? _controller.pause() : _controller.play(),
            child: VideoPlayer(_controller),
          )
              : const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),

        // Gradient Overlay: Ensures white text is readable against light video backgrounds
        Positioned.fill(
          child: IgnorePointer( // Allows clicks to pass through to the video player beneath
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.2, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Right-Side Interaction Menu (Likes, Comments, Share, Save)
        Positioned(
          bottom: 20,
          right: 12,
          child: Column(
            children: [
              _buildProfileIcon(widget.profileUrl),
              const SizedBox(height: 25),
              _buildActionIcon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                '$_likesCount',
                color: _isLiked ? Colors.red : Colors.white,
                onTap: _toggleLike,
              ),
              _buildActionIcon(Icons.chat_bubble_outline, '${_comments.length}', onTap: _showComments),
              _buildActionIcon(Icons.send_outlined, '11k', onTap: _showShareSheet),
              _buildActionIcon(
                _isSaved ? Icons.bookmark : Icons.bookmark_border,
                'Save',
                color: _isSaved ? Colors.red : Colors.white,
                onTap: _toggleSave,
              ),
            ],
          ),
        ),

        // Bottom-Left Metadata (Username, Follow Button, Caption, Audio Info)
        Positioned(
          bottom: 30,
          left: 15,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.username,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _toggleFollow,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _isFollowing ? "Following" : "Follow",
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.caption,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 12),
              // Scrolling Audio Ticker Placeholder
              Row(
                children: const [
                  Icon(Icons.music_note, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text("Original Audio", style: TextStyle(color: Colors.white, fontSize: 13)),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  // Widget Helper: Circular profile image with white border
  Widget _buildProfileIcon(String url) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
      child: CircleAvatar(radius: 24, backgroundImage: NetworkImage(url)),
    );
  }

  // Widget Helper: Standardized action button for the vertical menu
  Widget _buildActionIcon(IconData icon, String label, {Color color = Colors.white, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}