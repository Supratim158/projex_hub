import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/config.dart';
import 'detail/project_detail_page.dart';
import 'login/onboarding_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  String? userName;
  String? userEmail;
  bool isLoading = true;
  List<dynamic> projects = [];
  late SharedPreferences prefs;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    _loadImage();
    await _fetchUserData();
    await _fetchProjects();
  }

  void _loadImage() {
    String? savedPath = prefs.getString('profile_image_path');
    if (savedPath != null && File(savedPath).existsSync()) {
      setState(() {
        _imageFile = File(savedPath);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      prefs.setString('profile_image_path', pickedFile.path);
    }
  }

  Future<void> _fetchUserData() async {
    try {
      String? token = prefs.getString('token');
      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse(profile),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userName = data['name'];
          userEmail = data['email'];
          isLoading = false;
        });
      } else {
        print("Failed to fetch profile: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching profile: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchProjects() async {
    try {
      final response = await http.get(Uri.parse(formList));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          projects = data;
        });
      } else {
        print("Failed to load projects: ${response.body}");
      }
    } catch (e) {
      print("Error fetching projects: $e");
    }
  }

  void _logout() async {
    await prefs.remove('token');
    await prefs.remove('profile_image_path');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => OnboardingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7F7FD5), Color(0xFF86A8E7), Color(0xFF91EAE4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // 🔹 Main Content
            isLoading
                ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
                : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20), // add spacing below icons
                    _buildProfileSection(),
                    const SizedBox(height: 30),
                    _buildMainContent(),
                  ],
                ),
              ),
            ),

            // 🔹 Back and Logout Buttons Positioned Below Status Bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔙 Back Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    // 🚪 Logout Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: _logout,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : const AssetImage("assets/default_avatar.png") as ImageProvider,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.pencil,
                    color: Color(0xFF07536C),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          userName ?? 'Unknown User',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          userEmail ?? 'No Email',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "About Me",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Hey there! I’m a passionate learner exploring Flutter, Web3, and AI while building cool projects 🚀.",
            style: TextStyle(color: Colors.black87, height: 1.4),
          ),
          const SizedBox(height: 25),
          const Text(
            "My Projects",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 10),
          projects.isEmpty
              ? const Text(
            "No projects uploaded yet.",
            style: TextStyle(color: Colors.black54),
          )
              : ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return _buildProjectCard(projects[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    // ✅ Safely extract image URL
    String imageUrl = (project['projectImages'] != null &&
        project['projectImages'].isNotEmpty)
        ? project['projectImages'][0]['url']
        : 'https://via.placeholder.com/90';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDAD1FF), Color(0xFFF3E9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailPage(projectId: project['_id']),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image,
                      size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project['title'] ?? 'Untitled Project',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3C1E70),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      project['description'] ?? 'No description available.',
                      style: const TextStyle(
                        color: Color(0xFF4A3C6E),
                        fontSize: 13.5,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Color(0xFF5E35B1), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
