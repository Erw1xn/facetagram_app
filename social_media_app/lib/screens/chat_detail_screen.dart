import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatDetailScreen extends StatefulWidget {
  final String name;
  final String profileImg;
  final String receiverId;
  final String? sharedMediaUrl;

  const ChatDetailScreen({
    super.key,
    required this.name,
    required this.profileImg,
    required this.receiverId,
    this.sharedMediaUrl, // Optional
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    // Pagkabukas ng chat, kung may shinare na post, i-send agad!
    if (widget.sharedMediaUrl != null && widget.sharedMediaUrl!.isNotEmpty) {
      _sendSharedPost(widget.sharedMediaUrl!);
    }
  }

  String getChatRoomId() {
    List<String> ids = [currentUserId, widget.receiverId];
    ids.sort();
    return ids.join("_");
  }

  // FUNCTION PARA SA AUTO-FORWARD NG SHARED MEDIA
  void _sendSharedPost(String url) async {
    final roomId = getChatRoomId();

    // 1. I-save ang image/video URL sa Firestore messages
    await FirebaseFirestore.instance.collection('chats').doc(roomId).collection('messages').add({
      'senderId': currentUserId,
      'text': url, // Ang URL ang mismong message
      'timestamp': FieldValue.serverTimestamp(),
      'isMedia': true, // Indicator para sa UI
    });

    // 2. I-update ang huling chat sa Inbox
    await FirebaseFirestore.instance.collection('chats').doc(roomId).set({
      'lastMessage': "Shared a post 🖼️",
      'lastTime': FieldValue.serverTimestamp(),
      'users': [currentUserId, widget.receiverId],
    }, SetOptions(merge: true));

    // 3. Magpadala rin ng notification para sa shared post
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    String myName = userDoc.data()?['name'] ?? 'User';
    String myProfilePic = userDoc.data()?['profilePicUrl'] ?? '';

    await FirebaseFirestore.instance.collection('notifications').add({
      'senderId': currentUserId,
      'receiverId': widget.receiverId,
      'username': myName,
      'action': 'shared a post with you 🖼️',
      'imageUrl': myProfilePic,
      'timestamp': FieldValue.serverTimestamp(),
      'hasStory': false,
    });
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    String messageText = _controller.text.trim();
    _controller.clear();
    final roomId = getChatRoomId();

    // 1. KUNIN ANG DATA MO MULA SA 'USERS' COLLECTION
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    String myName = userDoc.data()?['name'] ?? 'User';
    String myProfilePic = userDoc.data()?['profilePicUrl'] ?? '';

    // 2. I-save ang message sa conversation
    await FirebaseFirestore.instance.collection('chats').doc(roomId).collection('messages').add({
      'senderId': currentUserId,
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 3. I-update ang main chat document (Inbox list)
    await FirebaseFirestore.instance.collection('chats').doc(roomId).set({
      'lastMessage': messageText,
      'lastTime': FieldValue.serverTimestamp(),
      'users': [currentUserId, widget.receiverId],
    }, SetOptions(merge: true));

    // 4. DYNAMIC NOTIFICATION: Nilagyan ng 'receiverId'
    await FirebaseFirestore.instance.collection('notifications').add({
      'senderId': currentUserId,           // IKAW ang nag-send
      'receiverId': widget.receiverId,     // SIYA ang makakatanggap (Dynamic ito!)
      'username': myName,                  // Pangalan mo (na makikita NIYA)
      'action': 'sent you a message 💬',
      'imageUrl': myProfilePic,
      'timestamp': FieldValue.serverTimestamp(),
      'hasStory': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            CircleAvatar(radius: 18, backgroundImage: NetworkImage(widget.profileImg)),
            const SizedBox(width: 10),
            Text(widget.name, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(getChatRoomId())
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    String time = "";
                    if (data['timestamp'] != null) {
                      DateTime date = (data['timestamp'] as Timestamp).toDate();
                      time = "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
                    }

                    return _buildMessageBubble(data['text'] ?? "", data['senderId'] == currentUserId, time);
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    final String cleanText = text.trim();

    // In-update na logic para ma-detect ang DALAWANG types:
    // Type 1: Common Image Extensions (para sa image mo)
    // Type 2: Random Link Patterns (para sa Picsum)
    bool isImage = cleanText.startsWith('http') &&
        (cleanText.toLowerCase().contains('.jpg') ||
            cleanText.toLowerCase().contains('.png') ||
            cleanText.toLowerCase().contains('.jpeg') ||
            cleanText.toLowerCase().contains('.webp') || // Dagdag extension
            cleanText.toLowerCase().contains('.gif') || // Dagdag extension
            cleanText.contains('fna.fbcdn.net') || // Specific for FB/Insta
            cleanText.contains('picsum.photos') || // <--- Eto ang para sa "random link" mo
            cleanText.contains('images.unsplash.com')); // Isang popular na random image link din

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(top: 5),
            padding: isImage ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: isImage
                ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                cleanText,
                width: 250,
                height: 250,
                fit: BoxFit.cover,
                cacheWidth: 500,
                // OPTIONAL: Magdagdag ng loading builder para sa mas magandang UI habang naglo-load
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 250,
                    height: 250,
                    color: Colors.grey[100],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(cleanText, style: const TextStyle(fontSize: 12, color: Colors.red)),
                  );
                },
              ),
            )
                : Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 2),
          child: Text(
            time,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar() {
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
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(25)),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(hintText: "Type a message...", border: InputBorder.none),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: _sendMessage),
        ],
      ),
    );
  }
}