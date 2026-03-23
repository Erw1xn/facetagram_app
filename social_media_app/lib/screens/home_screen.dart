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

  Post _generateRandomPost(int index) {
    final List<String> randomNames = ["TechCrunch", "National Geographic", "Traveler_99", "Daily News", "Chef Gordon", "Art Gallery"];
    final List<String> randomCaptions = [
      "Check out this amazing view from my morning hike! 🏔️",
      "Breaking: New technological advancement in AI is changing the world.",
      "Just finished cooking the best pasta of my life. 🍝",
      "Street photography in Tokyo is just different. 📸",
      "Thinking about how much Flutter has improved over the years."
    ];

    bool isNews = index % 3 == 0;

    return Post(
      userId: "system_generated", // Placeholder ID for random posts
      username: randomNames[index % randomNames.length],
      handle: "@${randomNames[index % randomNames.length].toLowerCase().replaceAll(' ', '_')}",
      profileUrl: "https://picsum.photos/id/${(index + 10) * 2}/200/200",
      content: randomCaptions[index % randomCaptions.length],
      mediaUrl: "https://picsum.photos/id/${index + 50}/800/600",
      type: isNews ? PostType.news : PostType.image,
      likes: "${(index + 1) * 12}",
      comments: "${index + 5}",
      newsTitle: isNews ? "The Future of Digital Connection" : null,
      newsSubtext: isNews ? "Exploring how social platforms are evolving in 2026." : null,
    );
  }

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

          final myDoc = allDocs.firstWhere((doc) => doc.id == myUid);
          final myData = myDoc.data() as Map<String, dynamic>;
          final String myName = myData['name'] ?? 'User';
          final String myPic = myData['profilePicUrl'] ?? 'https://www.w3schools.com/howto/img_avatar.png';

          final feedUsers = allDocs.where((doc) => doc.id != myUid).toList();

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: 1000,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _StoriesBar(allUsers: allDocs, currentUid: myUid);
              }

              int adjustedIndex = index - 1;

              if (adjustedIndex < feedUsers.length) {
                final userDoc = feedUsers[adjustedIndex];
                final userData = userDoc.data() as Map<String, dynamic>;
                final String userId = userDoc.id;

                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: userId))),
                  child: PostCard(
                    currentUserName: myName,
                    currentUserProfilePic: myPic,
                    post: Post(
                      userId: userId, // Pass the receiver's ID here
                      username: userData['name'] ?? 'User',
                      handle: userData['headline'] ?? '@user',
                      profileUrl: userData['profilePicUrl'] ?? 'https://www.w3schools.com/howto/img_avatar.png',
                      content: userData['bio'] ?? 'Hello! View my profile.',
                      mediaUrl: userData['coverPhotoUrl'] ?? 'https://picsum.photos/800/600',
                      type: PostType.image,
                      likes: "24",
                      comments: "3",
                    ),
                  ),
                );
              } else {
                final randomPost = _generateRandomPost(adjustedIndex);
                return PostCard(
                  currentUserName: myName,
                  currentUserProfilePic: myPic,
                  post: randomPost,
                );
              }
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
        children: [
          if (myDoc != null)
            StoryItem(
              name: "Your Story",
              imageUrl: (myDoc.data() as Map<String, dynamic>)['profilePicUrl'] ?? defaultImg,
              targetUserId: currentUid,
            ),

          ...otherUsers.map((userDoc) {
            final data = userDoc.data() as Map<String, dynamic>;
            final String otherUid = userDoc.id;

            return StoryItem(
              name: data['name'] ?? 'User',
              imageUrl: data['profilePicUrl'] ?? defaultImg,
              targetUserId: otherUid,
            );
          }).toList(),
        ],
      ),
    );
  }
}