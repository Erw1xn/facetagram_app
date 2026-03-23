import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/story_item.dart';
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
            surfaceTintColor: Colors.white,
            elevation: 0.5,
            title: GestureDetector(
              onTap: () => _triggerSearch(context, otherUsers),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Search friends, places, trends',
                          style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text("Recent Searches", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              _RecentSearchesBar(users: otherUsers),

              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text("Accounts to Explore", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              // Shows real users but with the toggle follow logic
              ...otherUsers.take(3).map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _AccountTile(
                  userId: doc.id,
                  name: data['name'] ?? 'User',
                  username: data['headline'] ?? '@user',
                  imageUrl: data['profilePicUrl'] ?? 'https://www.w3schools.com/howto/img_avatar.png',
                );
              }),

              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text("Popular Reels and Posts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const _PostsGrid(),
            ],
          ),
        );
      },
    );
  }
}

// --- FOLLOW TOGGLE LOGIC RESTORED ---
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
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: widget.userId))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(radius: 24, backgroundImage: NetworkImage(widget.imageUrl)),
      title: Text(widget.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(widget.username, style: const TextStyle(color: Colors.grey)),
      trailing: SizedBox(
        width: 110,
        height: 40,
        child: ElevatedButton(
          onPressed: () => setState(() => _isFollowing = !_isFollowing),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: _isFollowing ? Colors.white : const Color(0xFF1890FF),
            foregroundColor: _isFollowing ? Colors.black : Colors.white,
            side: _isFollowing ? const BorderSide(color: Colors.grey, width: 0.5) : BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(_isFollowing ? "Following" : "Follow", style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// --- POSTS GRID WITH IMAGE VIEWER RESTORED ---
class _PostsGrid extends StatelessWidget {
  const _PostsGrid();

  void _viewImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _viewImage(context, imageUrls[index]),
          child: Image.network(imageUrls[index], fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// --- RECENT SEARCHES BAR (RETAINS MOUSE POINTER) ---
class _RecentSearchesBar extends StatelessWidget {
  final List<DocumentSnapshot> users;
  const _RecentSearchesBar({required this.users});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 115,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final data = users[index].data() as Map<String, dynamic>;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: users[index].id))),
              child: StoryItem(
                name: data['name'] ?? 'User',
                imageUrl: data['profilePicUrl'] ?? 'https://www.w3schools.com/howto/img_avatar.png',
                isLive: false,
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- PEOPLE SEARCH DELEGATE ---
class PeopleSearchDelegate extends SearchDelegate {
  final List<DocumentSnapshot> allPeople;
  PeopleSearchDelegate({required this.allPeople});

  @override
  String get searchFieldLabel => "Search people...";

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty) IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();
  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = allPeople.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = data['name']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final data = results[index].data() as Map<String, dynamic>;
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(data['profilePicUrl'] ?? 'https://www.w3schools.com/howto/img_avatar.png')),
          title: Text(data['name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
          onTap: () {
            close(context, null);
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: results[index].id)));
          },
        );
      },
    );
  }
}