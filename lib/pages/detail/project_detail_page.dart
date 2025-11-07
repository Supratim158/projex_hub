import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:project_showcase/config/config.dart';
import 'package:project_showcase/pages/project_submit/project_submit_page.dart';
import '../../config/size_config.dart';
import '../../notifiers/animation_notifier.dart';
import 'package:provider/provider.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectId;

  const ProjectDetailPage({super.key, required this.projectId});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  Map<String, dynamic>? projectData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchProjectDetails();
  }

  Future<void> fetchProjectDetails() async {
    try {
      final apiUrl = Uri.parse("${projectDetail}${widget.projectId}");
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("✅ Project Data: ${decoded['data']}");
        setState(() {
          projectData = decoded['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching project: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _willPop(),
      child: Scaffold(
        body: isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.black),
        )
            : hasError
            ? const Center(
          child: Text(
            "Failed to load project details",
            style: TextStyle(color: Colors.black),
          ),
        )
            : Stack(
          children: [
            // 🔹 Top Gradient Background
            Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7F7FD5), Color(0xFF86A8E7), Color(0xFF91EAE4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // 🔹 Title Text on Top
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  "Project Details",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            // 🔹 Main White Rounded Container
            Positioned(
              top: MediaQuery.of(context).size.height * 0.20,
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                      bottomLeft: Radius.circular(35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            projectData?['title'] ??
                                "Untitled Project",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Center(
                          child: Text(
                            "${projectData?['category'] ?? 'N/A'}",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Center(
                          child: Text(
                            "Mentor: ${projectData?['mntorname'] ?? 'N/A'}",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // 🔹 Member Images
                        if (projectData?['memberImages'] != null &&
                            projectData!['memberImages'].isNotEmpty) ...[
                          const Text(
                            "Member Images:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: projectData!['memberImages']
                                .map<Widget>(
                                  (img) => ClipRRect(
                                borderRadius:
                                BorderRadius.circular(12),
                                child: Image.network(
                                  img['url'],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, _) =>
                                      Container(
                                        color: Colors.grey[300],
                                        width: 100,
                                        height: 100,
                                        child: const Icon(Icons.error),
                                      ),
                                ),
                              ),
                            )
                                .toList(),
                          ),
                          const SizedBox(height: 25),
                        ],

                        Text(
                          "Members: ${projectData?['mmbrname'] ?? 'N/A'}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),

                        Text(
                          "Description: ${projectData?['description'] ?? 'N/A'}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // 🔹 Clickable Link Section with Label
                        if (projectData?['link'] != null &&
                            projectData!['link'].isNotEmpty)
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Link: ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Flexible(
                                child: GestureDetector(
                                  onTap: () async {
                                    final Uri url = Uri.parse(
                                        projectData!['link']);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url,
                                          mode: LaunchMode
                                              .externalApplication);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                          content: Text(
                                              "Could not open the link")));
                                    }
                                  },
                                  child: Text(
                                    projectData!['link'],
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 16,
                                      decoration:
                                      TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          const Text(
                            "Link: N/A",
                            style: TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),

                        const SizedBox(height: 10),

                        Text(
                          "No of members: ${projectData?['mmbrno'] ?? 'N/A'}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),

                        Text(
                          "Year: ${projectData?['year'] ?? 'N/A'}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 🔹 Project Images
                        if (projectData?['projectImages'] != null &&
                            projectData!['projectImages']
                                .isNotEmpty) ...[
                          const Text(
                            "Project Images:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: projectData!['projectImages']
                                .map<Widget>(
                                  (img) => ClipRRect(
                                borderRadius:
                                BorderRadius.circular(12),
                                child: Image.network(
                                  img['url'],
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, _) =>
                                      Container(
                                        color: Colors.grey[300],
                                        width: 120,
                                        height: 120,
                                        child: const Icon(Icons.error),
                                      ),
                                ),
                              ),
                            )
                                .toList(),
                          ),
                          const SizedBox(height: 30),
                        ],

                        // 🔹 Files
                        if (projectData?['video'] != null ||
                            projectData?['ppt'] != null ||
                            projectData?['pdf'] != null) ...[
                          const Text(
                            "Project Files:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (projectData?['video'] != null)
                            FileTile(
                              title: "Watch Project Video",
                              icon: Icons.play_circle_fill,
                              color: Colors.redAccent,
                              url: projectData!['video'],
                            ),
                          if (projectData?['ppt'] != null)
                            FileTile(
                              title: "View PPT Presentation",
                              icon: Icons.slideshow,
                              color: Colors.orangeAccent,
                              url: projectData!['ppt'],
                            ),
                          if (projectData?['pdf'] != null)
                            FileTile(
                              title: "Open Project Report (PDF)",
                              icon: Icons.picture_as_pdf,
                              color: Colors.blueAccent,
                              url: projectData!['pdf'],
                            ),
                        ],
                        const SizedBox(height: 40),

                        // 🔹 Submit Button
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const ProjectSubmitPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFF4A148C),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 14),
                            ),
                            child: const Text(
                              "Submit Project",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 🔹 Back Button
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  _willPop();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _willPop() {
    Provider.of<AnimationNotifier>(context, listen: false)
        .playDetailToHomeAnimations();
    return Future.delayed(const Duration(milliseconds: 200), () => true);
  }
}

// ✅ FileTile Widget
class FileTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String url;
  final Color color;

  const FileTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.url,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          await launchUrl(Uri.parse(url),
              mode: LaunchMode.externalApplication);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Cannot open file: $e")),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.open_in_new, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
