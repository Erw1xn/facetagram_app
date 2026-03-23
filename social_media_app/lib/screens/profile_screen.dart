import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // If null, defaults to current user
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isPostsTab = true;

  // --- LOGIC: TARGET USER ---
  String? get targetUserId => widget.userId ?? _auth.currentUser?.uid;
  bool get isMe => targetUserId == _auth.currentUser?.uid;

  // --- DATABASE: UPDATE ---
  Future<void> _updateProfile(Map<String, dynamic> data) async {
    if (targetUserId == null) return;
    try {
      await _firestore.collection('users').doc(targetUserId).set(
        {
          ...data,
          'uid': targetUserId,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // --- UI: IMAGE PREVIEW ---
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
              onTap: () => Navigator.pop(context),
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

  // --- UI: EDIT DIALOG ---
  void _showEditProfileDialog(Map<String, dynamic> data) {
    TextEditingController nameCtrl = TextEditingController(text: data['name'] ?? '');
    TextEditingController headlineCtrl = TextEditingController(text: data['headline'] ?? '');
    TextEditingController bioCtrl = TextEditingController(text: data['bio'] ?? '');
    TextEditingController coverCtrl = TextEditingController(text: data['coverPhotoUrl'] ?? '');
    TextEditingController profilePicCtrl = TextEditingController(text: data['profilePicUrl'] ?? '');
    TextEditingController post1Ctrl = TextEditingController(text: data['postPic1Url'] ?? '');
    TextEditingController post2Ctrl = TextEditingController(text: data['postPic2Url'] ?? '');
    TextEditingController post3Ctrl = TextEditingController(text: data['postPic3Url'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.settings_suggest, color: Colors.blueAccent),
            SizedBox(width: 10),
            Text('Customize Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSectionHeader("Public Info"),
                _buildStyledField(nameCtrl, "Full Name", Icons.person_outline),
                _buildStyledField(headlineCtrl, "Headline", Icons.work_outline),
                _buildStyledField(bioCtrl, "Bio", Icons.description_outlined, maxLines: 2),
                _buildSectionHeader("Visuals"),
                _buildStyledField(coverCtrl, "Cover URL", Icons.image_outlined),
                _buildStyledField(profilePicCtrl, "Profile URL", Icons.face_retouching_natural),
                _buildSectionHeader("Gallery"),
                _buildStyledField(post1Ctrl, "Post 1 URL", Icons.photo_library_outlined),
                _buildStyledField(post2Ctrl, "Post 2 URL", Icons.photo_library_outlined),
                _buildStyledField(post3Ctrl, "Post 3 URL", Icons.photo_library_outlined),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _updateProfile({
                'name': nameCtrl.text,
                'headline': headlineCtrl.text,
                'bio': bioCtrl.text,
                'coverPhotoUrl': coverCtrl.text,
                'profilePicUrl': profilePicCtrl.text,
                'postPic1Url': post1Ctrl.text,
                'postPic2Url': post2Ctrl.text,
                'postPic3Url': post3Ctrl.text,
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (targetUserId == null) return const Scaffold(body: Center(child: Text("Please Login")));

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(targetUserId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        String name = userData['name'] ?? 'User';
        String headline = userData['headline'] ?? 'Facetagram Member';
        String bio = userData['bio'] ?? 'No bio yet.';
        String cover = userData['coverPhotoUrl'] ?? 'https://picsum.photos/800/600?random=1';
        String profile = userData['profilePicUrl'] ?? 'https://www.w3schools.com/howto/img_avatar.png';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(isMe ? 'My Profile' : name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: !isMe ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)) : null,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(cover, profile),
                const SizedBox(height: 65),
                _buildProfileInfo(name, headline, bio),
                if (isMe) _buildEditButton(userData),
                _buildTabs(),
                isPostsTab ? _buildPostGrid(userData) : _buildAboutSection(userData),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader(String cover, String profile) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        SizedBox(height: 180, width: double.infinity, child: Image.network(cover, fit: BoxFit.cover)),
        Positioned(
          bottom: -60,
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4.0)),
            child: CircleAvatar(radius: 60, backgroundImage: NetworkImage(profile)),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(String n, String h, String b) {
    return Column(
      children: [
        Text(n, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(h, style: const TextStyle(fontSize: 15, color: Colors.black54)),
            const SizedBox(width: 4),
            const Icon(Icons.verified, size: 16, color: Colors.blue),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(b, style: const TextStyle(fontSize: 13, color: Colors.black54), textAlign: TextAlign.center),
        ),
      ],
    );
  }

  Widget _buildEditButton(Map<String, dynamic> userData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showEditProfileDialog(userData),
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
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _tabItem("Posts", isPostsTab, () => setState(() => isPostsTab = true)),
        _tabItem("About", !isPostsTab, () => setState(() => isPostsTab = false)),
      ],
    );
  }

  Widget _tabItem(String title, bool active, VoidCallback onTap) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: active ? Colors.blue : Colors.grey)),
              const SizedBox(height: 8),
              Container(height: 2, color: active ? Colors.blue : Colors.transparent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostGrid(Map<String, dynamic> data) {
    List<String> images = [
      data['postPic1Url']?.toString() ?? '',
      data['postPic2Url']?.toString() ?? '',
      data['postPic3Url']?.toString() ?? '',
    ].where((url) => url.isNotEmpty).toList();

    if (images.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Text("No posts yet.", style: TextStyle(color: Colors.grey)),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: images.map((url) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showImagePreview(url),
          child: Image.network(url, fit: BoxFit.cover),
        ),
      )).toList(),
    );
  }

  Widget _buildAboutSection(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _aboutCard(Icons.person_outline, "Bio", data['bio'] ?? 'N/A', const Color(0xFFE3F2FD)),
          _aboutCard(Icons.school_outlined, "Education", "Global Reciprocal Colleges", const Color(0xFFF3E5F5)),
          _aboutCard(Icons.location_on_outlined, "Location", "Malabon City, Philippines", const Color(0xFFFFF3E0)),
        ],
      ),
    );
  }

  Widget _aboutCard(IconData icon, String title, String sub, Color bgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.blueAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(sub, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 12),
        child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
      ),
    );
  }

  Widget _buildStyledField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}