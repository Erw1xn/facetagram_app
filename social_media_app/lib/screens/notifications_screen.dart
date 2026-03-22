import 'package:flutter/material.dart';

// --- NOTIFICATIONS SCREEN: Displays user activity like likes, comments, and follows ---
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section: Large, bold title with custom padding and letter spacing
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 25, 20, 15),
          child: Text(
            'Notifications',
            style: TextStyle(
              fontSize: 30, // Large heading size
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
        ),

        // Scrollable List: Contains the categorized notification items
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(), // Provides the "stretch" effect on iOS/Android
            children: [
              _buildSectionTitle('New'), // Category header for recent alerts
              _buildNotificationItem(
                username: 'sarah_explore',
                imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                action: 'liked your photo "Redwoods Magic!" 🌲✨',
                time: '2h',
                hasStory: true, // Triggers the colorful ring around the profile pic
                trailing: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=200',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              _buildNotificationItem(
                username: 'alex_j',
                imageUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=200',
                action: 'commented: "Stunning light! 😍"',
                time: '3h',
              ),

              _buildSectionTitle('Earlier'), // Category header for older alerts
              _buildNotificationItem(
                username: 'mike_r',
                imageUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=200',
                action: 'mentioned you in a comment.',
                time: '5h',
              ),
              _buildNotificationItem(
                username: 'david_k',
                imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
                action: 'started following you.',
                time: '1d',
              ),
              _buildNotificationItem(
                username: 'clara_visions',
                imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
                action: 'tagged you in a post from Yosemite.',
                time: '2d',
                trailing: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=200',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              _buildNotificationItem(
                username: 'chloe_w',
                imageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
                action: 'saved your post "Redwoods Magic!"',
                time: '3d',
              ),
              _buildNotificationItem(
                username: 'mike_perez',
                imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
                action: 'tagged you in a post from Japan.',
                time: '2d',
                trailing: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // UI Helper: Builds the text labels for "New" and "Earlier" sections
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // UI Helper: Builds individual notification rows
  Widget _buildNotificationItem({
    required String username,
    required String imageUrl,
    required String action,
    required String time,
    bool hasStory = false,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        // Leading: Profile picture with an optional gradient border (if hasStory is true)
        leading: Container(
          width: 62,
          height: 62,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: hasStory
                ? const LinearGradient(
              colors: [Color(0xFFf9ce34), Color(0xFFee2a7b), Color(0xFF6228d7)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            )
                : null,
          ),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(imageUrl),
            ),
          ),
        ),
        // Title: Uses RichText to style the username differently from the action text
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15.5,
              height: 1.4,
            ),
            children: [
              TextSpan(
                text: username,
                style: const TextStyle(fontWeight: FontWeight.w800), // Bold username
              ),
              const TextSpan(text: ' '),
              TextSpan(text: action), // The activity description
              const TextSpan(text: ' '),
              TextSpan(
                text: time,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13.5), // Grey timestamp
              ),
            ],
          ),
        ),
        // Trailing: Optional widget (usually a thumbnail of the post)
        trailing: trailing,
        onTap: () {}, // Placeholder for interaction logic
      ),
    );
  }
}