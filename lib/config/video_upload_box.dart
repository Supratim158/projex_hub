// lib/config/video_upload_box.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class VideoUploadBox extends StatefulWidget {
  final String label;
  final Function(String? filePath) onVideoPicked;

  const VideoUploadBox({
    Key? key,
    required this.label,
    required this.onVideoPicked,
  }) : super(key: key);

  @override
  VideoUploadBoxState createState() => VideoUploadBoxState();
}

class VideoUploadBoxState extends State<VideoUploadBox> {
  String? _fileName;
  String? _filePath;

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _fileName = result.files.first.name;
        _filePath = result.files.first.path;
      });
      widget.onVideoPicked(_filePath);
    }
  }

  void clear() {
    setState(() {
      _fileName = null;
      _filePath = null;
    });
    widget.onVideoPicked(null);
  }

  // ---------- PUBLIC ----------
  String? get filePath => _filePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickVideo,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.play_circle_fill, color: Colors.blue, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _fileName ?? 'Upload ${widget.label}',
                style: TextStyle(
                  color: _fileName == null ? Colors.black45 : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}