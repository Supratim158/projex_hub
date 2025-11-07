// lib/config/photo_box.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoBox extends StatefulWidget {
  final int boxCount;
  final Function(List<XFile?>) onChanged;

  const PhotoBox({
    Key? key,
    required this.boxCount,
    required this.onChanged,
  }) : super(key: key);

  @override
  PhotoBoxState createState() => PhotoBoxState();
}

class PhotoBoxState extends State<PhotoBox> {
  final ImagePicker _picker = ImagePicker();
  late List<XFile?> _images;

  @override
  void initState() {
    super.initState();
    _images = List<XFile?>.filled(widget.boxCount, null);
  }

  // ---------- PUBLIC ----------
  List<XFile?> get images => _images;               // expose
  bool isFirstPhotoSelected() => _images[0] != null;

  void clear() {
    setState(() => _images = List<XFile?>.filled(widget.boxCount, null));
  }

  // ---------- PRIVATE ----------
  Future<void> _pickImage(int index) async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (img != null) {
      setState(() => _images[index] = img);
      widget.onChanged(_images);
    }
  }

  void _removeImage(int index) {
    setState(() => _images[index] = null);
    widget.onChanged(_images);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(widget.boxCount, (i) {
        final img = _images[i];
        return GestureDetector(
          onTap: () => _pickImage(i),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: i == 0 ? Colors.redAccent : Colors.grey.withOpacity(.5),
                width: 2,
              ),
              color: Colors.grey[100],
            ),
            child: img != null
                ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(img.path), fit: BoxFit.cover, width: 100, height: 100),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(i),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            )
                : Center(
              child: Icon(
                Icons.add_a_photo_outlined,
                color: i == 0 ? Colors.redAccent : Colors.grey[600],
                size: 30,
              ),
            ),
          ),
        );
      }),
    );
  }
}