import 'package:flutter/material.dart';

// --- STORY ITEM: A reusable widget for the horizontal story bar that opens a full-screen view ---
class StoryItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isLive;

  const StoryItem({
    super.key,
    required this.name,
    required this.imageUrl,
    this.isLive = false,
  });

  // --- UI Logic: Function to launch the Full-Screen Story Overlay ---
  void _showStory(BuildContext context) {
    // showGeneralDialog allows for a custom full-screen overlay without standard page transitions
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Story",
      pageBuilder: (context, anim1, anim2) {
        // Local variable for the heart reaction state
        bool isLiked = false;

        // StatefulBuilder is CRITICAL here: It allows the dialog to update its own UI (the heart)
        // because showGeneralDialog's pageBuilder is not part of the main widget's build cycle.
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  // 1. BACKGROUND: The Main Story Image
                  // SizedBox.expand ensures the image fills the entire screen
                  SizedBox.expand(
                    child: Image.network(
                      'https://picsum.photos/seed/${name.hashCode + 1}/1080/1920',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // 2. GRADIENT OVERLAY: Improves legibility of white text on top of bright images
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                        stops: const [0.0, 0.2, 0.8, 1.0],
                      ),
                    ),
                  ),

                  // 3. HEADER: Displays User Avatar, Name, and Close button
                  Positioned(
                    top: 50,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                          ),
                        ),
                        const Spacer(),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. INTERACTION: The Heart (Like) button at the bottom right
                  Positioned(
                    bottom: 40,
                    right: 20,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          // Updates the 'isLiked' variable within the StatefulBuilder scope
                          setState(() => isLiked = !isLiked);
                        },
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showStory(context), // Triggers the full-screen view
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              // STORY RING: Gradient border logic
              Container(
                padding: const EdgeInsets.all(3), // Thickness of the gradient ring
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    // Changes color palette if the user is 'Live' (Red/Orange) vs standard Story (Instagram colors)
                    colors: isLive
                        ? [Colors.red, Colors.deepOrange]
                        : [
                      const Color(0xFF833AB4), // Purple
                      const Color(0xFFFD1D1D), // Red
                      const Color(0xFFFCAF45), // Yellow/Orange
                    ],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(2), // White gap between ring and image
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              // User Name label below the story ring
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}