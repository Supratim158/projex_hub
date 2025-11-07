import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'detail/project_detail_page.dart';

class AllProjectsPage extends StatefulWidget {
  const AllProjectsPage({super.key});

  @override
  State<AllProjectsPage> createState() => _AllProjectsPageState();
}

class _AllProjectsPageState extends State<AllProjectsPage> {
  String selectedCategory = "All";
  String searchQuery = "";
  bool isLoading = true;
  List<dynamic> allProjects = [];

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      final response = await http.get(Uri.parse(allList));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data =
            jsonResponse['data'] ?? jsonResponse; // fallback if no wrapper

        setState(() {
          allProjects = data;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load projects: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching projects: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch projects"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final List<String> categories = [
    "All",
    "AI",
    "ML",
    "IoT",
    "App",
    "Web",
    "Others",
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProjects = allProjects.where((project) {
      final title = (project['title'] ?? "").toString();
      final description = (project['description'] ?? "").toString();
      final category = (project['category'] ?? "Others").toString();

      final matchesCategory =
          selectedCategory == "All" || category == selectedCategory;
      final matchesSearch = title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          description.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

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
        child: SafeArea(
          child: Stack(
            children: [
              // Main Content
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // 🔹 Page Title
                    const Center(
                      child: Text(
                        "All Projects",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔍 Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() => searchQuery = value);
                        },
                        decoration: const InputDecoration(
                          hintText: "Search projects...",
                          prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 🟪 Category Chips
                    SizedBox(
                      height: 45,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = cat == selectedCategory;
                          return ChoiceChip(
                            label: Text(
                              cat,
                              style: TextStyle(
                                color:
                                isSelected ? Colors.white : Colors.deepPurple,
                                fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: Colors.deepPurple,
                            backgroundColor: Colors.white,
                            shape: const StadiumBorder(
                              side: BorderSide(color: Colors.deepPurple, width: 1),
                            ),
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = cat;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 📦 Project List
                    Container(
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
                      padding: const EdgeInsets.all(18),
                      child: isLoading
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple,
                        ),
                      )
                          : filteredProjects.isEmpty
                          ? Center(
                        child: Text(
                          "No projects found 😕",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                          : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredProjects.length,
                        itemBuilder: (context, index) {
                          final project = filteredProjects[index];
                          return _buildProjectCard(project);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Back Button (top-left)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 💫 Project Card
  Widget _buildProjectCard(Map<String, dynamic> project) {
    // ✅ Extract image URL correctly from backend
    String imageUrl = 'https://via.placeholder.com/150';

    if (project['projectImages'] != null &&
        project['projectImages'] is List &&
        project['projectImages'].isNotEmpty &&
        project['projectImages'][0]['url'] != null) {
      imageUrl = project['projectImages'][0]['url'];
    }

    // ✅ Ensure full URL
    if (!imageUrl.startsWith('http')) {
      imageUrl = 'http://192.168.151.130:3000$imageUrl';
    }

    print("🖼 Final Image URL: $imageUrl");

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
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      project['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3C1E70),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      project['description'] ?? '',
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
