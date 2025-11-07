// lib/config/file_upload_box.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadBox extends StatefulWidget {
  final String label;
  final Function(String? filePath) onFilePicked;

  const FileUploadBox({
    Key? key,
    required this.label,
    required this.onFilePicked,
  }) : super(key: key);

  @override
  FileUploadBoxState createState() => FileUploadBoxState();
}

class FileUploadBoxState extends State<FileUploadBox> {
  String? _fileName;
  String? _filePath;          // stored path

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ppt', 'pptx', 'pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _fileName = result.files.first.name;
        _filePath = result.files.first.path;
      });
      widget.onFilePicked(_filePath);
    }
  }

  void clear() {
    setState(() {
      _fileName = null;
      _filePath = null;
    });
    widget.onFilePicked(null);
  }

  // ---------- PUBLIC ----------
  String? get filePath => _filePath;   // expose

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickFile,
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
            const Icon(Icons.upload_file, color: Colors.blue, size: 32),
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