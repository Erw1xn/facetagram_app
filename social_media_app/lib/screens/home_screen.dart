import 'package:flutter/material.dart';
// Importing specific screen and widget files for navigation and UI components
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
// Make sure to import your login screen here
import 'login_screen.dart';

// 1. MAIN NAVIGATION WRAPPER
// This widget handles the primary scaffold and the bottom navigation switching logic
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Tracks the currently selected index of the bottom navigation bar
  int _currentIndex = 0;

  // List of main views mapped to the bottom navigation items
  final List<Widget> _pages = [
    const _HomeFeedView(),
    const SearchScreen(),
    const ReelsScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack maintains the state of each page so they don't reload when switching tabs
      body: IndexedStack(index: _currentIndex, children: _pages),

      // --- FLOATING CHATBOT ICON (Meta AI Style) ---
      // Positioned at the bottom right to trigger the ChatBot feature
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: SizedBox(
          height: 60,
          width: 60,
          child: FloatingActionButton(
            onPressed: () {
              // Navigates to the ChatBot dedicated screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatBotScreen()),
              );
            },
            backgroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/chatbot_icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Bottom bar used to navigate between the 5 primary app sections
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library_outlined), label: 'Reels'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifications'),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage('https://scontent.fcrk3-3.fna.fbcdn.net/v/t39.30808-6/489699479_1904480607045773_3263197683851780059_n.jpg?stp=dst-jpg_s206x206_tt6&_nc_cat=107&ccb=1-7&_nc_sid=3da8dc&_nc_eui2=AeFESeA4xxUk_NPqR6b8hYQFhmYDBTJWVU-GZgMFMlZVT91Cre6u1ld2INOjPfeGlyjOMcGx_TMM5JHxawD_iZh6&_nc_ohc=OedOfWvaC-QQ7kNvwFa7Nlr&_nc_oc=AdoffsgsMgNyeAKMe7sp4E_41Qn-1wI5_YlBtL0tSU-fQWpIKuM2fkIxau4dGuRRhgY&_nc_zt=23&_nc_ht=scontent.fcrk3-3.fna&_nc_gid=f7K5xupWvsMO1PgJgaLuOQ&_nc_ss=7a32e&oh=00_AfzUMNwxU6Lpsu-B-hlV6t3WN_odft2UCBII-ASsCSCAKQ&oe=69C55D34'),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// 2. THE HOME FEED
// Private widget that renders the scrollable feed of posts and stories
class _HomeFeedView extends StatefulWidget {
  const _HomeFeedView();

  @override
  State<_HomeFeedView> createState() => _HomeFeedViewState();
}

class _HomeFeedViewState extends State<_HomeFeedView> {
  // Controller to monitor scroll position for infinite loading
  final ScrollController _scrollController = ScrollController();

  // Initial list of post data to be displayed in the feed
  final List<Post> _allPosts = [
    Post(
      username: "Sarah Lynn",
      handle: "@sarah_explore",
      profileUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150",
      content: "Hiking through the redwoods was magic! 🌲✨",
      mediaUrl: "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800",
      type: PostType.image,
      likes: "1.2K",
      comments: "84",
    ),
    Post(
      username: "Chef Julian",
      handle: "@jules_eats",
      profileUrl: "https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150",
      content: "Sunday brunch is incomplete without perfectly poached eggs. 🍳☕ #FoodieLife",
      mediaUrl: "https://images.unsplash.com/photo-1525351484163-7529414344d8?w=800",
      type: PostType.image,
      likes: "850",
      comments: "42",
    ),
    Post(
      username: "MetaFlow Tech",
      handle: "Sponsored",
      profileUrl: "https://images.unsplash.com/photo-1614850523296-d8c1af93d400?w=150",
      content: "The future of mobile development is faster than you think.",
      mediaUrl: "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800",
      type: PostType.news,
      newsTitle: "AI Integration in 2026",
      newsSubtext: "Learn how modern apps are leveraging local LLMs.",
      likes: "45K",
      comments: "1.1K",
    ),
    Post(
      username: "Minimalist Daily",
      handle: "@mod_arch",
      profileUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150",
      content: "Clean lines and natural light. The perfect workspace doesn't exi— 😍",
      mediaUrl: "https://images.unsplash.com/photo-1497366216548-37526070297c?w=800",
      type: PostType.image,
      likes: "2.4K",
      comments: "115",
    ),
    Post(
      username: "Mike Ross",
      handle: "@mike_r",
      profileUrl: "https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150",
      content: "Late night coding session. Almost done with the new update! ☕",
      mediaUrl: "https://images.unsplash.com/photo-1587620962725-abab7fe55159?w=800",
      type: PostType.image,
      likes: "320",
      comments: "22",
    ),
    Post(
      username: "Wanderlust",
      handle: "@globe_trotter",
      profileUrl: "https://images.unsplash.com/photo-1531123897727-8f129e16fd3c?w=150",
      content: "Waking up to this view in Switzerland makes every hike worth it. 🏔️❄️",
      mediaUrl: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800",
      type: PostType.image,
      likes: "10K",
      comments: "312",
    ),
    Post(
      username: "Fit Life",
      handle: "@gym_guru",
      profileUrl: "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=150",
      content: "Consistency is key. Push past your limits today! 💪",
      mediaUrl: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800",
      type: PostType.image,
      likes: "5.1K",
      comments: "180",
    ),
    Post(
      username: "Pixel Artist",
      handle: "@digital_art",
      profileUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150",
      content: "New project incoming. What do you think of this palette? 🎨",
      mediaUrl: "https://images.unsplash.com/photo-1550684848-fac1c5b4e853?w=800",
      type: PostType.image,
      likes: "980",
      comments: "55",
    ),
    Post(
      username: "Vinyl Collector",
      handle: "@music_vibes",
      profileUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150",
      content: "Nothing beats the warmth of a classic record. 🎶",
      mediaUrl: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=800",
      type: PostType.image,
      likes: "720",
      comments: "38",
    ),
    Post(
      username: "Coffee Culture",
      handle: "@brew_master",
      profileUrl: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=150",
      content: "The art of the perfect pour. ☕✨",
      mediaUrl: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800",
      type: PostType.image,
      likes: "2.1K",
      comments: "45",
    ),
    Post(
      username: "Ocean Vibes",
      handle: "@surf_daily",
      profileUrl: "https://images.unsplash.com/photo-1505118380757-91f5f45d8de0?w=150",
      content: "Catching the first waves at dawn. 🌊🏄‍♂️",
      mediaUrl: "https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=800",
      type: PostType.image,
      likes: "4.3K",
      comments: "92",
    ),
    Post(
      username: "Tech Insider",
      handle: "Sponsored",
      profileUrl: "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=150",
      content: "The best gadget releases of the quarter.",
      mediaUrl: "https://images.unsplash.com/photo-1591337676887-a217a6970a8a?w=800",
      type: PostType.news,
      newsTitle: "Foldable Tech Peak",
      newsSubtext: "Why 2026 is the year of the fold.",
      likes: "15K",
      comments: "2K",
    ),
    Post(
      username: "Street Style",
      handle: "@fashion_hub",
      profileUrl: "https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=150",
      content: "OOTD: Urban exploration vibes. 🔥",
      mediaUrl: "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800",
      type: PostType.image,
      likes: "3200",
      comments: "77",
    ),
    Post(
      username: "Home Decor",
      handle: "@interior_inspo",
      profileUrl: "https://images.unsplash.com/photo-1513694203232-719a280e022f?w=150",
      content: "Minimalism is an art form. 🌱🏠",
      mediaUrl: "https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800",
      type: PostType.image,
      likes: "6.7K",
      comments: "120",
    ),
    Post(
      username: "Space Explorers",
      handle: "Sponsored",
      profileUrl: "https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=150",
      content: "New Mars rover landing footage released.",
      mediaUrl: "https://images.unsplash.com/photo-1454789548928-9efd52dc4031?w=800",
      type: PostType.news,
      newsTitle: "Life on Mars?",
      newsSubtext: "Recent soil samples show promising results.",
      likes: "88K",
      comments: "12K",
    ),
    Post(
      username: "Auto World",
      handle: "@speed_beast",
      profileUrl: "https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=150",
      content: "The pure power of high-performance engineering. 🏎️💨",
      mediaUrl: "https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800",
      type: PostType.image,
      likes: "9.2K",
      comments: "210",
    ),
    Post(
      username: "Bakery Bliss",
      handle: "@sweet_treats",
      profileUrl: "https://images.unsplash.com/photo-1495147466023-ac5c588e2e94?w=150",
      content: "Morning rituals: Croissants and quiet. 🥐☕",
      mediaUrl: "https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=800",
      type: PostType.image,
      likes: "1.8K",
      comments: "56",
    ),
    Post(
      username: "Night Owl",
      handle: "@city_lights",
      profileUrl: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=150",
      content: "Tokyo nights hits different. 🌃✨",
      mediaUrl: "https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=800",
      type: PostType.image,
      likes: "11K",
      comments: "400",
    ),
  ];

  // List of posts currently visible to the user
  late List<Post> _displayedPosts;
  // Flag to prevent multiple concurrent load requests
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize the displayed list and attach a listener to the scroll controller
    _displayedPosts = List.from(_allPosts);
    _scrollController.addListener(_onScroll);
  }

  // Logic to detect when the user has scrolled near the bottom of the list
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading) {
      _loadMorePosts();
    }
  }

  // Simulates fetching more data from a server and appends it to the list
  void _loadMorePosts() async {
    setState(() => _isLoading = true);
    // Artificial delay to mimic network latency
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _displayedPosts.addAll(_allPosts);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    // Clean up the scroll controller when the widget is removed from the tree
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0.5,
        // Header title containing the app logo and gradient-styled text
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
                'Facetagram',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white),
              ),
            ),
          ],
        ),
        // App bar buttons for Marketplace and Messaging navigation
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketplaceScreen()));
            },
            icon: const Icon(Icons.storefront_outlined, color: Colors.black, size: 28),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MessagesScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Image.asset('assets/images/messenger_logo.png', height: 35, width: 50),
            ),
          ),
          // --- LOGOUT BUTTON ADDED HERE ---
          IconButton(
            onPressed: () {
              // Navigates back to LoginScreen and removes all previous routes
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
      // The main scrollable area of the Home Feed
      body: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: _displayedPosts.length + 2,
        itemBuilder: (context, index) {
          // The first item is always the horizontal Story bar
          if (index == 0) return const _StoriesBar();

          // Handles the display of the loading indicator at the very end of the list
          if (index == _displayedPosts.length + 1) {
            return _isLoading
                ? const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
                : const SizedBox.shrink();
          }

          // Renders an individual post card based on the current data index
          return PostCard(post: _displayedPosts[index - 1]);
        },
      ),
    );
  }
}

// 3. STORIES BAR
// Stateless widget that displays the horizontal list of user stories at the top of the feed
class _StoriesBar extends StatelessWidget {
  const _StoriesBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 115,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: const [
          // List of story items with specific profile images and labels
          StoryItem(name: "Your Story", imageUrl: 'https://scontent.fcrk3-3.fna.fbcdn.net/v/t39.30808-6/489699479_1904480607045773_3263197683851780059_n.jpg?stp=dst-jpg_s206x206_tt6&_nc_cat=107&ccb=1-7&_nc_sid=3da8dc&_nc_eui2=AeFESeA4xxUk_NPqR6b8hYQFhmYDBTJWVU-GZgMFMlZVT91Cre6u1ld2INOjPfeGlyjOMcGx_TMM5JHxawD_iZh6&_nc_ohc=OedOfWvaC-QQ7kNvwFa7Nlr&_nc_oc=AdoffsgsMgNyeAKMe7sp4E_41Qn-1wI5_YlBtL0tSU-fQWpIKuM2fkIxau4dGuRRhgY&_nc_zt=23&_nc_ht=scontent.fcrk3-3.fna&_nc_gid=f7K5xupWvsMO1PgJgaLuOQ&_nc_ss=7a32e&oh=00_AfzUMNwxU6Lpsu-B-hlV6t3WN_odft2UCBII-ASsCSCAKQ&oe=69C55D34'),
          StoryItem(name: "Alex J.", imageUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=150', isLive: true),
          StoryItem(name: "Sarah L.", imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'),
          StoryItem(name: "Mike R.", imageUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150'),
          StoryItem(name: "Chloe W.", imageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150'),
          StoryItem(name: "David K.", imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150'),
        ],
      ),
    );
  }
}