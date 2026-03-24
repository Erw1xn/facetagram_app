import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_detail_screen.dart';

class MessagesScreen extends StatefulWidget {
  final String? sharedMediaUrl; // Dagdagan ito
  const MessagesScreen({super.key, this.sharedMediaUrl}); // I-update ang constructor

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final String defaultImg = 'https://www.w3schools.com/howto/img_avatar.png';

  void _showSearch(BuildContext context, List<DocumentSnapshot> users) {
    showSearch(
      context: context,
      delegate: MessageSearchDelegate(allUsers: users, defaultImg: defaultImg, currentUserId: currentUserId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chats',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 28, letterSpacing: -0.5)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No users found"));

          final allUsers = snapshot.data!.docs.where((doc) => doc.id != currentUserId).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GestureDetector(
                  onTap: () => _showSearch(context, allUsers),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey, size: 20),
                        SizedBox(width: 10),
                        Text("Search", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 10),
                    _buildActiveNowSection(allUsers),
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Divider(height: 1, thickness: 0.1, color: Colors.grey),
                    ),
                    ...allUsers.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildChatItem(
                        context,
                        data['name'] ?? 'User',
                        data['profilePicUrl'] ?? defaultImg,
                        doc.id,
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveNowSection(List<DocumentSnapshot> users) {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final data = users[index].data() as Map<String, dynamic>;
          final String name = data['name'] ?? 'User';
          final String img = data['profilePicUrl'] ?? defaultImg;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(name: name, profileImg: img, receiverId: users[index].id))),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(radius: 30, backgroundImage: NetworkImage(img)),
                      Positioned(bottom: 5, right: 5, child: Container(height: 14, width: 14, decoration: BoxDecoration(color: const Color(0xFF44B700), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(name.split(' ')[0], style: const TextStyle(fontSize: 13, color: Colors.black87))
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, String name, String img, String receiverId) {
    // Generate the same Room ID logic to fetch the preview
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String roomId = ids.join("_");

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('chats').doc(roomId).snapshots(),
      builder: (context, snapshot) {
        String lastMsg = "Tap to chat";
        String time = "Now";

        if (snapshot.hasData && snapshot.data!.exists) {
          var chatData = snapshot.data!.data() as Map<String, dynamic>;
          lastMsg = chatData['lastMessage'] ?? "Tap to chat";
          if (chatData['lastTime'] != null) {
            DateTime dt = (chatData['lastTime'] as Timestamp).toDate();
            time = "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
          }
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  name: name,
                  profileImg: img,
                  receiverId: receiverId,
                  // Make sure 'widget.sharedMediaUrl' is available in your State class
                  sharedMediaUrl: widget.sharedMediaUrl,
                ),
              ),
            );
          },
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(img),
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          subtitle: Text(
            lastMsg,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            time,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      },
    );
  }
}

class MessageSearchDelegate extends SearchDelegate {
  final List<DocumentSnapshot> allUsers;
  final String defaultImg;
  final String currentUserId;
  MessageSearchDelegate({required this.allUsers, required this.defaultImg, required this.currentUserId});

  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();
  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = allUsers.where((doc) => (doc['name'] ?? '').toString().toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final data = results[index].data() as Map<String, dynamic>;
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(data['profilePicUrl'] ?? defaultImg)),
          title: Text(data['name'] ?? 'User'),
          onTap: () {
            close(context, null);
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => ChatDetailScreen(name: data['name'], profileImg: data['profilePicUrl'], receiverId: results[index].id)));
          },
        );
      },
    );
  }
}