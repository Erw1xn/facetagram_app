import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_bot_screen.dart';
import '../widgets/post_card.dart';
import '../models/post_model.dart';
import '../widgets/story_item.dart';
import 'reels_screen.dart';
import 'search_screen.dart';
import 'marketplace_screen.dart';
import 'messages_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Widget> _pages = [
    const _HomeFeedView(),
    const SearchScreen(),
    const ReelsScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(_auth.currentUser?.uid).snapshots(),
      builder: (context, snapshot) {
        String userImageUrl = 'https://www.w3schools.com/howto/img_avatar.png';

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          userImageUrl = data['profilePicUrl'] ?? userImageUrl;
        }

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: _pages),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black,
            backgroundColor: Colors.white,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              const BottomNavigationBarItem(icon: Icon(Icons.video_library_outlined), label: 'Reels'),
              const BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifications'),
              BottomNavigationBarItem(
                icon: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(userImageUrl),
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeFeedView extends StatelessWidget {
  const _HomeFeedView();

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0.5,
        title: Row(
          children: [
            Image.asset('assets/images/splash_logo.png', height: 50),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF1877F2), Color(0xFF833AB4), Color(0xFFC13584), Color(0xFFF77737)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: const Text(
                'FaceTagram',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketplaceScreen())),
            icon: const Icon(Icons.storefront_outlined, color: Colors.black, size: 28),
          ),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MessagesScreen())),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Image.asset('assets/images/messenger_logo.png', height: 35, width: 50),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.black, size: 28),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: SizedBox(
          height: 60, width: 60,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatBotScreen())),
            backgroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/images/chatbot_icon.png', fit: BoxFit.contain),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final String? myUid = _auth.currentUser?.uid;
          final allDocs = snapshot.data!.docs;

          // --- 1. EXTRACT YOUR OWN DATA FOR COMMENTS ---
          // This looks for your own document in the collection to get your name and photo
          final myDoc = allDocs.firstWhere((doc) => doc.id == myUid);
          final myData = myDoc.data() as Map<String, dynamic>;
          final String myName = myData['name'] ?? 'User';
          final String myPic = myData['profilePicUrl'] ?? 'https://www.w3schools.com/howto/img_avatar.png';

          // --- 2. FILTER FEED: Remove yourself from the post feed ---
          final feedUsers = allDocs.where((doc) => doc.id != myUid).toList();

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: feedUsers.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _StoriesBar(allUsers: allDocs, currentUid: myUid);
              }

              final userDoc = feedUsers[index - 1];
              final userData = userDoc.data() as Map<String, dynamic>;
              final String userId = userDoc.id;

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(userId: userId),
                      ),
                    );
                  },
                  child: PostCard(
                    // --- FIXED: Pass the required user data to PostCard ---
                    currentUserName: myName,
                    currentUserProfilePic: myPic,
                    post: Post(
                      username: userData['name'] ?? 'User',
                      handle: userData['headline'] ?? '@user',
                      profileUrl: userData['profilePicUrl'] ?? 'https://www.w3schools.com/howto/img_avatar.png',
                      content: userData['bio'] ?? 'Hello! View my profile.',
                      mediaUrl: userData['coverPhotoUrl'] ?? 'https://picsum.photos/800/600',
                      type: PostType.image,
                      likes: "0",
                      comments: "0",
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StoriesBar extends StatelessWidget {
  final List<QueryDocumentSnapshot> allUsers;
  final String? currentUid;

  const _StoriesBar({required this.allUsers, required this.currentUid});

  @override
  Widget build(BuildContext context) {
    QueryDocumentSnapshot? myDoc;
    List<QueryDocumentSnapshot> otherUsers = [];

    for (var doc in allUsers) {
      if (doc.id == currentUid) {
        myDoc = doc;
      } else {
        otherUsers.add(doc);
      }
    }

    const String defaultImg = 'https://www.w3schools.com/howto/img_avatar.png';

    return Container(
      color: Colors.white,
      height: 115,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          if (myDoc != null)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                child: StoryItem(
                  name: "Your Story",
                  imageUrl: (myDoc.data() as Map<String, dynamic>)['profilePicUrl'] ?? defaultImg,
                ),
              ),
            ),

          ...otherUsers.map((userDoc) {
            final data = userDoc.data() as Map<String, dynamic>;
            final String otherUid = userDoc.id;

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userId: otherUid),
                    ),
                  );
                },
                child: StoryItem(
                  name: data['name'] ?? 'User',
                  imageUrl: data['profilePicUrl'] ?? defaultImg,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}