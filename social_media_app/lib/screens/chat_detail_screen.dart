import 'package:flutter/material.dart';

// --- CHAT DETAIL SCREEN: Handles individual conversation threads ---
class ChatDetailScreen extends StatefulWidget {
  final String name;
  final String profileImg;

  // Constructor requires the recipient's name and image URL
  const ChatDetailScreen({super.key, required this.name, required this.profileImg});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  // 1. Controller to clear the text field after sending and access the input text
  final TextEditingController _controller = TextEditingController();

  // 2. A dynamic list to store messages.
  // Each entry is a Map. "isMe: true" identifies messages sent by the current user.
  final List<Map<String, dynamic>> _messages = [
    {"text": "Hey! Did you see the new post?", "isMe": false},
    {"text": "Yeah! The hiking photos looked amazing. 🌲", "isMe": true},
    {"text": "We should go there next weekend!", "isMe": false},
    {"text": "I'm down! Let's invite Alex too.", "isMe": true},
  ];

  // 3. The Send Function: Validates input, updates state, and clears the field
  void _sendMessage() {
    // Only proceed if the text isn't just empty spaces
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        // Adds the new message to the local list
        _messages.add({
          "text": _controller.text.trim(),
          "isMe": true, // User-sent messages are always true
        });
      });
      _controller.clear(); // Resets the input field to empty
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.blue),
        // Title Row: Displays Profile Pic, Name, and Status
        title: Row(
          children: [
            CircleAvatar(radius: 18, backgroundImage: NetworkImage(widget.profileImg)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const Text("Active now",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
      body: Column(
        children: [
          // 4. Using ListView.builder for performance and dynamic updates.
          // Expanded ensures the list takes up all available space above the input bar.
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // Returns a styled bubble for each message in the list
                return _buildMessageBubble(
                  _messages[index]["text"],
                  _messages[index]["isMe"],
                );
              },
            ),
          ),
          // Persistent input bar at the bottom of the screen
          _buildMinimalInputBar(),
        ],
      ),
    );
  }

  // UI Helper: Builds the individual message bubbles
  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      // Sent messages go Right, received messages go Left
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          // Blue for user, light grey for others
          color: isMe ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: isMe ? Colors.white : Colors.black, fontSize: 16),
        ),
      ),
    );
  }

  // UI Helper: Builds the text input area and send button
  Widget _buildMinimalInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _controller, // Link the controller to the field
                onSubmitted: (_) => _sendMessage(), // Allows sending via keyboard "Enter" key
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Action button to trigger the send logic
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}