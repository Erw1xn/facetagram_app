import 'package:flutter/material.dart';
import 'chat_detail_screen.dart';

// --- MESSAGES SCREEN: The main inbox view displaying all conversations ---
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // Mock Data: A list of maps representing chat users, their last message, and unread status
  final List<Map<String, String>> chatUsers = const [
    {'name': 'Sarah Lynn', 'msg': 'Sent a photo', 'time': '12:45 PM', 'img': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?sig=10', 'unread': 'true'},
    {'name': 'Alex Johnson', 'msg': 'Haha that\'s crazy! 😂', 'time': '1:30 PM', 'img': 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?sig=20', 'unread': 'false'},
    {'name': 'Mike Ross', 'msg': 'You: See you at the office.', 'time': 'Yesterday', 'img': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?sig=30', 'unread': 'false'},
    {'name': 'Chloe White', 'msg': 'Can you send the file?', 'time': 'Yesterday', 'img': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?sig=40', 'unread': 'true'},
    {'name': 'David King', 'msg': 'Let\'s grab coffee soon.', 'time': 'Saturday', 'img': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?sig=50', 'unread': 'false'},
    {'name': 'Emma Watson', 'msg': 'The meeting was moved.', 'time': 'Saturday', 'img': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?sig=60', 'unread': 'false'},
  ];

  // Logic: Triggers the built-in Flutter Search interface using the custom delegate below
  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: MessageSearchDelegate(chatUsers: chatUsers),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white, // Prevents the AppBar from changing color when the list scrolls
        elevation: 0,
        centerTitle: false,
        leading: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text('Chats',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 28, letterSpacing: -0.5)),
      ),
      body: Column(
        children: [
          // UI Component: Custom Search Bar (Triggered on tap)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showSearch(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12)
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey, size: 20),
                      SizedBox(width: 10),
                      Text("Search", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(), // Provides iOS-style "over-scroll" behavior
              children: [
                const SizedBox(height: 10),
                // Section: Horizontal list showing active users
                _buildActiveNowSection(),
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Divider(height: 1, thickness: 0.1, color: Colors.grey),
                ),
                // Section: Mapping the chatUsers data into individual ListTiles
                ...chatUsers.map((user) => _buildChatItem(
                    context,
                    user['name']!,
                    user['msg']!,
                    user['time']!,
                    user['img']!,
                    user['unread'] == 'true'
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UI Helper: Builds the horizontal "Active Now" circular avatars
  Widget _buildActiveNowSection() {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: chatUsers.length,
        itemBuilder: (context, index) {
          final user = chatUsers[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatDetailScreen(name: user['name']!, profileImg: user['img']!))
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        // Profile Picture Container with subtle border
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1)
                          ),
                          child: CircleAvatar(radius: 30, backgroundImage: NetworkImage(user['img']!)),
                        ),
                        // Online indicator (Green Dot)
                        Positioned(
                          bottom: 5, right: 5,
                          child: Container(
                              height: 14, width: 14,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF44B700),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2)
                              )
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Displays only the first name for brevity
                    Text(user['name']!.split(' ')[0],
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87))
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // UI Helper: Builds an individual chat row with unread logic
  Widget _buildChatItem(BuildContext context, String name, String msg, String time, String img, bool unread) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatDetailScreen(name: name, profileImg: img))
        ),
        leading: CircleAvatar(radius: 30, backgroundImage: NetworkImage(img)),
        title: Text(name, style: TextStyle(
            fontWeight: unread ? FontWeight.w700 : FontWeight.w500, // Bold if unread
            fontSize: 16,
            color: Colors.black87
        )),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(msg,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: unread ? Colors.black : Colors.grey[600],
                  fontWeight: unread ? FontWeight.w600 : FontWeight.w400
              )
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: TextStyle(fontSize: 12, color: unread ? Colors.blue : Colors.grey)),
            // Blue dot indicator for unread messages
            if (unread)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 10, width: 10,
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              )
          ],
        ),
      ),
    );
  }
}

// --- SEARCH DELEGATE: Manages the logic for searching through the user list ---
class MessageSearchDelegate extends SearchDelegate {
  final List<Map<String, String>> chatUsers;
  MessageSearchDelegate({required this.chatUsers});

  // Action: Display a clear button when text is present
  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty) IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  // Action: Return to the previous screen
  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  // Helper: Filters the user list based on the user's input (query)
  Widget _buildSearchResults() {
    final results = chatUsers.where((u) => u['name']!.toLowerCase().contains(query.toLowerCase())).toList();

    if (results.isEmpty) {
      return const Center(child: Text("No users found.", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(user['img']!)),
            title: Text(user['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(user['msg']!),
            onTap: () {
              close(context, null); // Close the search view
              // Navigate directly to the chat detail from search results
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatDetailScreen(name: user['name']!, profileImg: user['img']!)),
              );
            },
          ),
        );
      },
    );
  }
}