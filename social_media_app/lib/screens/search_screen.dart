import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _triggerSearch(BuildContext context, List<DocumentSnapshot> allUsers) {
    showSearch(
      context: context,
      delegate: PeopleSearchDelegate(allPeople: allUsers),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final String? myUid = _auth.currentUser?.uid;
        final allDocs = snapshot.data!.docs;
        final otherUsers = allDocs.where((doc) => doc.id != myUid).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: GestureDetector(
              onTap: () => _triggerSearch(context, otherUsers),
              child: Container(
                height: 40,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey, size: 20),
                      SizedBox(width: 10),
                      Text('Search friends, places, trends', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const Padding(padding: EdgeInsets.fromLTRB(16, 24, 16, 16), child: Text("Accounts to Explore", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              ...otherUsers.take(3).map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _AccountTile(
                  userId: doc.id,
                  name: data['name'] ?? 'User',
                  username: data['headline'] ?? '@user',
                  imageUrl: data['profilePicUrl'] ?? 'https://www.w3schools.com/howto/img_avatar.png',
                );
              }),
              const Padding(padding: EdgeInsets.fromLTRB(16, 24, 16, 16), child: Text("Popular Reels and Posts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              const _PostsGrid(),
            ],
          ),
        );
      },
    );
  }
}

class _AccountTile extends StatefulWidget {
  final String userId;
  final String name;
  final String username;
  final String imageUrl;

  const _AccountTile({required this.userId, required this.name, required this.username, required this.imageUrl});

  @override
  State<_AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends State<_AccountTile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).snapshots(),
      builder: (context, snapshot) {
        bool isFollowing = false;
        if (snapshot.hasData && snapshot.data!.exists) {
          List following = (snapshot.data!.data() as Map<String, dynamic>)['following'] ?? [];
          isFollowing = following.contains(widget.userId);
        }

        return ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen(userId: widget.userId)),
          ),
          leading: CircleAvatar(radius: 24, backgroundImage: NetworkImage(widget.imageUrl)),
          title: Text(widget.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text(widget.username, style: const TextStyle(color: Colors.grey)),
          trailing: SizedBox(
            width: 110,
            height: 40,
            child: ElevatedButton(
              onPressed: () async {
                if (currentUser == null) return;

                // 1. Reference sa IYONG document
                final myDocRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

                // 2. Reference sa KANILANG document
                final theirDocRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);

                try {
                  if (isFollowing) {
                    // --- UNFOLLOW LOGIC ---
                    await myDocRef.update({
                      'following': FieldValue.arrayRemove([widget.userId])
                    });
                    await theirDocRef.update({
                      'followers': FieldValue.arrayRemove([currentUser.uid])
                    });
                  } else {
                    // --- FOLLOW LOGIC ---
                    await myDocRef.update({
                      'following': FieldValue.arrayUnion([widget.userId])
                    });
                    await theirDocRef.update({
                      'followers': FieldValue.arrayUnion([currentUser.uid])
                    });

                    // --- NOTIFICATION ---
                    // Gamitin ang snapshot data para makuha ang pangalan at image mo
                    final myData = snapshot.data?.data() as Map<String, dynamic>?;
                    String myName = myData?['name'] ?? 'Someone';
                    String myImg = myData?['profilePicUrl'] ?? '';

                    await FirebaseFirestore.instance.collection('notifications').add({
                      'action': 'started following you 👤',
                      'receiverId': widget.userId,
                      'senderId': currentUser.uid,
                      'timestamp': FieldValue.serverTimestamp(),
                      'username': myName,
                      'imageUrl': myImg,
                    });
                  }
                } catch (e) {
                  debugPrint("Error updating follow: $e");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.white : const Color(0xFF1890FF),
                foregroundColor: isFollowing ? Colors.black : Colors.white,
                side: isFollowing ? const BorderSide(color: Colors.grey, width: 0.5) : BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isFollowing ? "Following" : "Follow",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PostsGrid extends StatelessWidget {
  const _PostsGrid();

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = [
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600',
      'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=600',
      'https://images.unsplash.com/photo-1533105079780-92b9be482077?w=600',
      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=600',
      'https://images.unsplash.com/photo-1502791451862-7bd8c1df43a7?w=600',
      'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=600',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) => Image.network(imageUrls[index], fit: BoxFit.cover),
    );
  }
}

class PeopleSearchDelegate extends SearchDelegate {
  final List<DocumentSnapshot> allPeople;
  PeopleSearchDelegate({required this.allPeople});

  @override
  List<Widget>? buildActions(BuildContext context) => [if (query.isNotEmpty) IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();
  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = allPeople.where((doc) {
      final name = (doc.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final data = results[index].data() as Map<String, dynamic>;
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(data['profilePicUrl'] ?? '')),
          title: Text(data['name'] ?? 'User'),
          onTap: () {
            close(context, null);
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: results[index].id)));
          },
        );
      },
    );
  }
}