import 'package:flutter/material.dart';

// --- MAIN ENTRY POINT ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Facetagram App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.blue,
        useMaterial3: true, // Enables latest Material Design components and styling
      ),
      home: const ProfileScreen(),
      debugShowCheckedModeBanner: false, // Removes the red "Debug" corner banner
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- Editable State Variables ---
  // These hold the profile info that can be updated via the Edit Dialog
  String name = 'Erwin Jacaba';
  String headline = 'Facetagram Developer';
  String bio = 'IT 304 | Group Limentation';

  // --- UI State ---
  // Controls which content is visible: the Grid (Posts) or the List (About)
  bool isPostsTab = true;

  // --- Constants ---
  // Static image URLs used for the cover, profile, and post images
  final String coverPhotoUrl = 'https://picsum.photos/800/600?random=11';
  final String profilePicUrl = 'https://scontent.fcrk3-3.fna.fbcdn.net/v/t39.30808-6/489699479_1904480607045773_3263197683851780059_n.jpg?stp=dst-jpg_s206x206_tt6&_nc_cat=107&ccb=1-7&_nc_sid=3da8dc&_nc_eui2=AeFESeA4xxUk_NPqR6b8hYQFhmYDBTJWVU-GZgMFMlZVT91Cre6u1ld2INOjPfeGlyjOMcGx_TMM5JHxawD_iZh6&_nc_ohc=OedOfWvaC-QQ7kNvwFa7Nlr&_nc_oc=AdoffsgsMgNyeAKMe7sp4E_41Qn-1wI5_YlBtL0tSU-fQWpIKuM2fkIxau4dGuRRhgY&_nc_zt=23&_nc_ht=scontent.fcrk3-3.fna&_nc_gid=LZZpsOGYpauoH7CxhM80Rg&_nc_ss=7a30f&oh=00_Afzdts5XgTwGYFBespWug6gm5BPkyS5NDLZcM1dUUMpKig&oe=69C47C34';
  final String postPic1Url = 'https://scontent.fcrk3-1.fna.fbcdn.net/v/t1.15752-9/638841263_1393737818902392_454766865756108419_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=9f807c&_nc_eui2=AeGlKrNwbv-pQnO1iyx2qbjGG45tJmK-dNYbjm0mYr501jhubD3CZ5EPzaWV2Z3j2FHWnEUJHdHJOZzl7zRPwB3P&_nc_ohc=AzIPOBIenvkQ7kNvwFDLawo&_nc_oc=Ado96UfHpaBJlIm2Wq56YpdL0CwwPOxudXbga8HiPmwBtMexoL7FvwPjwJRCLDOQXM4&_nc_zt=23&_nc_ht=scontent.fcrk3-1.fna&_nc_ss=7a32e&oh=03_Q7cD4wHsQTBu9vTxRdewQpyJaW_qG0QPaNL1CQ1k-yC1Z2WBaw&oe=69E61896';
  final String postPic2Url = 'https://scontent.fcrk3-1.fna.fbcdn.net/v/t1.15752-9/633939704_2161357598024467_1394752558457948910_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=9f807c&_nc_eui2=AeEu-KClg4Q2g_i0d4ENslTq8pp-xKsP_-Pymn7Eqw__413BhuMKHyE-e2AneSoRh0S7n8DBmbgNTey5foZFRf5_&_nc_ohc=JVo3XM0GrQQQ7kNvwH2sVuQ&_nc_oc=AdriiT6aFMxaFSWJX5umJxIOl66UuZvw3Kf8VD7-aYI1pDxInygfFFY9Q5djSqMELDI&_nc_zt=23&_nc_ht=scontent.fcrk3-1.fna&_nc_ss=7a30f&oh=03_Q7cD4wEFe1IWHs7BboXe6FcMuhjTxBncpmLyL7Nb3g7Jx0OXow&oe=69E62AFB';
  final String postPic3Url = 'https://scontent.fcrk3-1.fna.fbcdn.net/v/t1.15752-9/646326356_1434937704194115_4725436788070263061_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=9f807c&_nc_eui2=AeHyInDnTOTHJtX6UQ-oP9n9WVFXqZzxDthZUVepnPEO2BdXUm1t9OIXJSke36Rp-lXjl7CaPlTyya_xhrTGqX0v&_nc_ohc=GLYr9Q0tpH4Q7kNvwGbmsX-&_nc_oc=AdqKVh8wiZjSy7vgY_8gOVfAYbUbM8fyg4ozC7BRFDgXJ7C515tBqnTyQBfGCk8iOWY&_nc_zt=23&_nc_ht=scontent.fcrk3-1.fna&_nc_ss=7a30f&oh=03_Q7cD4wEaf4as94VHIdPCk6gphSkekgHK267MABIfNEdg25ZZ6w&oe=69E6223D';

  // --- Image Preview Logic ---
  // Displays an image in a full-screen interactive dialog
  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context), // Close on background tap
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.9),
                child: InteractiveViewer(
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40, right: 20),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Edit Profile Logic ---
  // Opens a dialog with text fields to update profile variables
  void _showEditProfileDialog() {
    TextEditingController nameCtrl = TextEditingController(text: name);
    TextEditingController headlineCtrl = TextEditingController(text: headline);
    TextEditingController bioCtrl = TextEditingController(text: bio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: headlineCtrl, decoration: const InputDecoration(labelText: 'Headline')),
            TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: 'Bio')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // Updates state and closes the dialog
              setState(() {
                name = nameCtrl.text;
                headline = headlineCtrl.text;
                bio = bioCtrl.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section: Stack used to overlap profile picture on cover photo
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none, // Allows the profile picture to hang outside the Stack bounds
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Image.network(coverPhotoUrl, fit: BoxFit.cover),
                ),
                Positioned(
                  bottom: -60, // Shifts the profile picture halfway down past the cover photo
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4.0),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(profilePicUrl),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 65), // Spacer to account for the overlapping profile picture

            // Profile Details Section
            Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(headline, style: const TextStyle(fontSize: 15, color: Colors.black54)),
                    const SizedBox(width: 4),
                    const Icon(Icons.rocket_launch, size: 16, color: Colors.blue),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    bio,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            // Action Button: Full-width button to trigger Edit mode
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showEditProfileDialog,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),

            // Tabs Section: Switcher for Posts/About content
            Row(
              children: [
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => setState(() => isPostsTab = true),
                      child: Column(
                        children: [
                          Text('Posts', style: TextStyle(fontWeight: FontWeight.bold, color: isPostsTab ? Colors.blue : Colors.grey)),
                          const SizedBox(height: 8),
                          Container(height: 2, color: isPostsTab ? Colors.blue : Colors.transparent),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => setState(() => isPostsTab = false),
                      child: Column(
                        children: [
                          Text('About', style: TextStyle(fontWeight: FontWeight.bold, color: !isPostsTab ? Colors.blue : Colors.grey)),
                          const SizedBox(height: 8),
                          Container(height: 2, color: !isPostsTab ? Colors.blue : Colors.transparent),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Conditional Content: Renders GridView for Posts or Aesthetic Cards for About
            if (isPostsTab)
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  shrinkWrap: true, // Allows GridView to behave within a SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(), // Scroll is handled by the parent
                  children: [
                    _buildPostItem(postPic1Url),
                    _buildPostItem(postPic2Url),
                    _buildPostImage(postPic3Url),
                  ],
                ),
              )
            else
            // Aesthetic About UI section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildAestheticAboutCard(
                      Icons.person_outline_rounded,
                      "Personal Bio",
                      bio,
                      const Color(0xFFE3F2FD),
                    ),
                    _buildAestheticAboutCard(
                      Icons.school_outlined,
                      "Education",
                      "Student at Global Reciprocal Colleges",
                      const Color(0xFFF3E5F5),
                    ),
                    _buildAestheticAboutCard(
                      Icons.auto_awesome_outlined,
                      "Project Mission",
                      "Creating Limentation: The best of Facebook & Instagram.",
                      const Color(0xFFE8F5E9),
                    ),
                    _buildAestheticAboutCard(
                      Icons.location_on_outlined,
                      "Location",
                      "Malabon City, Philippines",
                      const Color(0xFFFFF3E0),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Aesthetic Card Helper: Creates a styled list item for the About tab
  Widget _buildAestheticAboutCard(IconData icon, String title, String subtitle, Color bgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Grid Item Helper: Displays an image that triggers the preview logic on tap
  Widget _buildPostItem(String imageUrl) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showImagePreview(imageUrl),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }

  // Alternate Grid Item Helper
  Widget _buildPostImage(String imageUrl) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showImagePreview(imageUrl),
        child: ClipRRect(
          child: Image.network(imageUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }
}