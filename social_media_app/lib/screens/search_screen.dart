import 'package:flutter/material.dart';
import '../widgets/story_item.dart';

// --- SEARCH SCREEN: The main discovery hub for users to find content and accounts ---
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Database: Mock list of searchable users containing names, handles, and image URLs
  final List<Map<String, String>> peopleDatabase = [
    {'name': 'Maria K.', 'user': '@maria_adventures', 'url': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150'},
    {'name': 'Alex J.', 'user': '@alex_j', 'url': 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=150'},
    {'name': 'Sarah L.', 'user': '@sarah_dev', 'url': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'},
    {'name': 'Mike R.', 'user': '@mike_runs', 'url': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150'},
    {'name': 'Chloe W.', 'user': '@chloe_designs', 'url': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150'},
    {'name': 'Travel Vistas', 'user': '@travelvistas', 'url': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=150'},
    {'name': 'Artisan Bakers', 'user': '@artisanbakers', 'url': 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=150'},
  ];

  // Function: Triggers the Flutter Search Delegate to open the full-screen search UI
  void _triggerSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: PeopleSearchDelegate(allPeople: peopleDatabase),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        // UI Component: Tappable search bar container that acts as a trigger
        title: GestureDetector(
          onTap: () => _triggerSearch(context),
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
        children: [
          // Section: Header for the horizontal recent searches list
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text("Recent Searches", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const _RecentSearchesBar(),

          // Section: Header for the recommended accounts list
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Text("Accounts to Explore", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const _AccountTile(name: "Maria K.", username: "@maria_adventures", initialFollowing: false, imageUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150"),
          const _AccountTile(name: "Travel Vistas", username: "@travelvistas", initialFollowing: true, imageUrl: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=150"),
          const _AccountTile(name: "Artisan Bakers", username: "@artisanbakers", initialFollowing: false, imageUrl: "https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=150"),

          // Section: Header for the visual discovery grid
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Text("Popular Reels and Posts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const _PostsGrid(),
        ],
      ),
    );
  }
}

// --- PEOPLE SEARCH DELEGATE: Manages the live filtering and result display ---
class PeopleSearchDelegate extends SearchDelegate {
  final List<Map<String, String>> allPeople;
  PeopleSearchDelegate({required this.allPeople});

  @override
  String get searchFieldLabel => "Search people...";

  // Function: Provides the "Clear" button to empty the current search query
  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty) IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  // Function: Provides the "Back" button to exit the search interface
  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  // Function: Displays the final list of results when a user confirms a search
  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  // Function: Displays real-time suggestions as the user types
  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  // Helper Function: Filters the database and builds the list of user tiles
  Widget _buildSearchResults() {
    final results = allPeople
        .where((person) =>
    person['name']!.toLowerCase().contains(query.toLowerCase()) ||
        person['user']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return const Center(child: Text("No users found.", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(results[index]['url']!)),
          title: Text(results[index]['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(results[index]['user']!),
          onTap: () => close(context, null),
        );
      },
    );
  }
}

// --- ACCOUNT TILE COMPONENT: A reusable row for user recommendations with follow logic ---
class _AccountTile extends StatefulWidget {
  final String name;
  final String username;
  final bool initialFollowing;
  final String imageUrl;
  const _AccountTile({required this.name, required this.username, required this.initialFollowing, required this.imageUrl});
  @override
  State<_AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends State<_AccountTile> {
  late bool _isFollowing;

  // Function: Initializes following state from widget parameters
  @override
  void initState() { super.initState(); _isFollowing = widget.initialFollowing; }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(radius: 24, backgroundColor: Colors.grey[200], backgroundImage: NetworkImage(widget.imageUrl)),
      title: Text(widget.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(widget.username, style: const TextStyle(color: Colors.grey)),
      trailing: SizedBox(
        width: 110, height: 40,
        child: ElevatedButton(
          // Function: Toggles the local follow/unfollow state on press
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

// --- RECENT SEARCHES BAR: A horizontal list displaying recent user interactions ---
class _RecentSearchesBar extends StatelessWidget {
  const _RecentSearchesBar();

  @override
  Widget build(BuildContext context) {
    // List: Mock data for previously searched individuals
    final List<Map<String, dynamic>> recentData = [
      {"name": "Alex J.", "url": 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=150'},
      {"name": "Sarah L.", "url": 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'},
      {"name": "Mike R.", "url": 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150'},
      {"name": "Chloe W.", "url": 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150'},
      {"name": "David K.", "url": 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150'},
    ];
    return Container(
      height: 115,
      padding: const EdgeInsets.symmetric(vertical: 10),
      // Function: Builds a horizontal scrollable view using StoryItem widgets
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: recentData.length,
        itemBuilder: (context, index) => StoryItem(name: recentData[index]['name'], imageUrl: recentData[index]['url'], isLive: false),
      ),
    );
  }
}

// --- POSTS GRID: A dense grid layout showcasing popular trending content ---
class _PostsGrid extends StatelessWidget {
  const _PostsGrid();

  // Function: Displays an image in a high-focus dialog overlay when tapped
  void _viewImage(BuildContext context, String url) {
    showDialog(
        context: context,
        builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(url, fit: BoxFit.contain))
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    // List: Collection of high-resolution image URLs for the discovery feed
    final List<String> imageUrls = [
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600', 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=600',
      'https://images.unsplash.com/photo-1533105079780-92b9be482077?w=600', 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=600',
      'https://images.unsplash.com/photo-1502791451862-7bd8c1df43a7?w=600', 'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=600',
      'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=600', 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=600',
      'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=600',
    ];
    // Function: Generates a 3-column responsive grid of post thumbnails
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _viewImage(context, imageUrls[index]),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Image.network(imageUrls[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
              const Padding(padding: EdgeInsets.all(6.0), child: Icon(Icons.movie_filter_rounded, color: Colors.white, size: 22)),
            ],
          ),
        ),
      ),
    );
  }
}