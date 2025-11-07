import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:video_player/video_player.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/size_config.dart';

class Summary extends StatefulWidget {
  final String summary;
  final String link;
  final String mmbrs;
  final String year;
  final String videoPath; // asset or local file
  final String pptPath; // Presentation PDF
  final String pdfPath; // Project Report PDF
  final List<String> imagePaths; // 1–4 images

  const Summary({
    super.key,
    required this.summary,
    required this.videoPath,
    required this.pptPath,
    required this.pdfPath,
    required this.imagePaths,
    required this.link,
    required this.mmbrs,
    required this.year,
  });

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();

    // 🎬 Initialize video controller
    if (widget.videoPath.startsWith("assets/")) {
      _videoController = VideoPlayerController.asset(widget.videoPath);
    } else {
      _videoController = VideoPlayerController.file(File(widget.videoPath));
    }

    _videoController.initialize().then((_) {
      setState(() {
        _isVideoInitialized = true;
      });
    }).catchError((error) {
      debugPrint("Video initialization failed: $error");
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  // ✅ Function to open PDF files (from assets or local storage)
  Future<void> _openFile(String path) async {
    try {
      File fileToOpen;

      if (path.startsWith("assets/")) {
        final byteData = await rootBundle.load(path);
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${path.split('/').last}');
        await tempFile.writeAsBytes(byteData.buffer.asUint8List());
        fileToOpen = tempFile;
      } else {
        fileToOpen = File(path);
      }

      final result = await OpenFile.open(fileToOpen.path);
      debugPrint("File open result: ${result.message}");
    } catch (e) {
      debugPrint("Error opening file: $e");
    }
  }

  // 🌐 Fixed URL Launcher Function
  Future<void> _launchURL(String url) async {
    try {
      String formattedUrl = url.trim();
      if (!formattedUrl.startsWith('http')) {
        formattedUrl = 'https://$formattedUrl';
      }

      final Uri uri = Uri.parse(formattedUrl);

      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        debugPrint('Could not launch $formattedUrl');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  // 🖼️ Open image gallery
  void _openImageGallery(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: widget.imagePaths.length,
                builder: (context, index) {
                  final path = widget.imagePaths[index];
                  final imageProvider = path.startsWith("assets/")
                      ? AssetImage(path)
                      : FileImage(File(path)) as ImageProvider;

                  return PhotoViewGalleryPageOptions(
                    imageProvider: imageProvider,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  );
                },
                pageController: PageController(initialPage: initialIndex),
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),

              // 🔙 Back Button
              Positioned(
                top: 40,
                left: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎥 Full-screen video player
  void _openFullScreenVideo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenVideoPlayer(controller: _videoController),
      ),
    );
  }

  // 🕓 Hide controls after delay
  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _showControls = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.imagePaths;
    final imageCount = images.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📝 Description
          Text(
            "Description",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18),
          ),
          SizedBox(height: SizeConfig.defaultHeight * 0.5),
          Text(
            widget.summary,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // 🌐 Clickable Link
          Text(
            "Link",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18),
          ),
          SizedBox(height: SizeConfig.defaultHeight * 0.5),
          InkWell(
            onTap: () => _launchURL(widget.link),
            child: Row(
              children: [
                const Icon(Icons.link, color: Colors.blue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.link,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 👥 Members
          Text(
            "No of Members",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18),
          ),
          Text(
            widget.mmbrs,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // 📅 Year
          Text(
            "Year",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18),
          ),
          Text(
            widget.year,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // 🖼️ Project Images
          if (images.isNotEmpty) ...[
            Text(
              "Project Images",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: imageCount > 4 ? 4 : imageCount,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  final isLastVisible = index == 3 && imageCount > 4;
                  final path = images[index];
                  final imageProvider = path.startsWith("assets/")
                      ? AssetImage(path)
                      : FileImage(File(path)) as ImageProvider;

                  return GestureDetector(
                    onTap: () => _openImageGallery(index),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        if (isLastVisible)
                          Container(
                            color: Colors.black45,
                            child: Center(
                              child: Text(
                                "+${imageCount - 4}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 🎬 Project Demo Video
          Text(
            "Project Demo Video",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _openFullScreenVideo,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black12,
              ),
              child: _isVideoInitialized
                  ? GestureDetector(
                onTap: () {
                  setState(() => _showControls = !_showControls);
                  if (_videoController.value.isPlaying) _startHideTimer();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: VideoPlayer(_videoController),
                    ),
                    if (_showControls)
                      IconButton(
                        iconSize: 50,
                        color: Colors.white,
                        icon: Icon(
                          _videoController.value.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_videoController.value.isPlaying) {
                              _videoController.pause();
                            } else {
                              _videoController.play();
                              _startHideTimer();
                            }
                          });
                        },
                      ),
                    if (_showControls)
                      const Positioned(
                        right: 8,
                        bottom: 8,
                        child: Icon(Icons.fullscreen, color: Colors.white),
                      ),
                  ],
                ),
              )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          const SizedBox(height: 20),

          // 📊 Presentation PDF
          Text(
            "Presentation (PDF)",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _openFile(widget.pptPath),
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.deepOrange),
                    SizedBox(width: 10),
                    Text(
                      "Open Presentation PDF",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 📄 Report PDF
          Text(
            "Project Report (PDF)",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _openFile(widget.pdfPath),
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      "Open Report PDF",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  const _FullScreenVideoPlayer({required this.controller});

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  bool _showControls = true;
  Timer? _hideTimer;

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      setState(() => _showControls = false);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() => _showControls = !_showControls);
          if (controller.value.isPlaying) _startHideTimer();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
            if (_showControls)
              Positioned(
                top: 40,
                left: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () {
                      controller.pause();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            if (_showControls)
              IconButton(
                iconSize: 60,
                color: Colors.white,
                icon: Icon(
                  controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                ),
                onPressed: () {
                  setState(() {
                    if (controller.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                      _startHideTimer();
                    }
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
