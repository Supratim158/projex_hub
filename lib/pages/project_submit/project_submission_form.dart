// lib/screens/project_submission_form.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../config/config.dart';
import '../../config/text_field.dart';
import '../../config/file_upload_box.dart';
import '../../config/photo_box.dart';
import '../../config/video_upload_box.dart';
import '../componets/bottom_nav_bar.dart';

class ProjectSubmissionForm extends StatefulWidget {
  const ProjectSubmissionForm({super.key});

  @override
  State<ProjectSubmissionForm> createState() => _ProjectSubmissionFormState();
}

class _ProjectSubmissionFormState extends State<ProjectSubmissionForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _mentorCtrl = TextEditingController();
  final _membersNoCtrl = TextEditingController();
  final _membersNameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();

  // Keys
  final _projPhotoKey = GlobalKey<PhotoBoxState>();
  final _memPhotoKey = GlobalKey<PhotoBoxState>();
  final _pptKey = GlobalKey<FileUploadBoxState>();
  final _pdfKey = GlobalKey<FileUploadBoxState>();
  final _videoKey = GlobalKey<VideoUploadBoxState>();

  // ---------- SUBMIT ----------
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!(_projPhotoKey.currentState?.isFirstPhotoSelected() ?? false)) {
      _snack('Please select the **first** project photo', error: true);
      return;
    }

    _snack('Uploading…');

    final request = http.MultipartRequest('POST', Uri.parse(formSubmit));

    // Text fields
    request.fields.addAll({
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'link': _linkCtrl.text.trim(),
      'mntorname': _mentorCtrl.text.trim(),
      'mmbrno': _membersNoCtrl.text.trim(),
      'mmbrname': _membersNameCtrl.text.trim(),
      'category': _categoryCtrl.text.trim(),
      'year': _yearCtrl.text.trim(),
      // 'userId': 'your_user_id',   // <-- add if you have auth
    });

    // Project images (projectImage1 … projectImage4)
    final projImgs = _projPhotoKey.currentState?.images ?? [];
    for (int i = 0; i < projImgs.length && i < 4; i++) {
      if (projImgs[i] != null) {
        request.files.add(await http.MultipartFile.fromPath('projectImage${i + 1}', projImgs[i]!.path));
      }
    }

    // Member images
    final memImgs = _memPhotoKey.currentState?.images ?? [];
    for (int i = 0; i < memImgs.length && i < 4; i++) {
      if (memImgs[i] != null) {
        request.files.add(await http.MultipartFile.fromPath('memberImage${i + 1}', memImgs[i]!.path));
      }
    }

    // Video
    final videoPath = _videoKey.currentState?.filePath;
    if (videoPath == null) return _snack('Video is required', error: true);
    request.files.add(await http.MultipartFile.fromPath('video', videoPath));

    // PPT
    final pptPath = _pptKey.currentState?.filePath;
    if (pptPath == null) return _snack('PPT is required', error: true);
    request.files.add(await http.MultipartFile.fromPath('ppt', pptPath));

    // PDF
    final pdfPath = _pdfKey.currentState?.filePath;
    if (pdfPath == null) return _snack('PDF Report is required', error: true);
    request.files.add(await http.MultipartFile.fromPath('pdf', pdfPath));

    // Send
    try {
      final streamed = await request.send();
      final respStr = await streamed.stream.bytesToString();
      final resp = http.Response(respStr, streamed.statusCode);
      final json = jsonDecode(resp.body);

      if (json['status'] == true) {
        _clearForm();
        _snack('Project submitted successfully!', success: true);
      } else {
        _snack(json['message'] ?? 'Submission failed', error: true);
      }
    } catch (e) {
      _snack('Network error: $e', error: true);
    }
  }

  void _snack(String msg, {bool error = false, bool success = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : (error ? Colors.red : null),
      ),
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _titleCtrl.clear();
    _descCtrl.clear();
    _linkCtrl.clear();
    _mentorCtrl.clear();
    _membersNoCtrl.clear();
    _membersNameCtrl.clear();
    _categoryCtrl.clear();
    _yearCtrl.clear();

    _projPhotoKey.currentState?.clear();
    _memPhotoKey.currentState?.clear();
    _pptKey.currentState?.clear();
    _pdfKey.currentState?.clear();
    _videoKey.currentState?.clear();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _linkCtrl.dispose();
    _mentorCtrl.dispose();
    _membersNoCtrl.dispose();
    _membersNameCtrl.dispose();
    _categoryCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Text fields ----------
            CustomTextField(labelText: "Project Title", hintText: "Enter title", errorMessage: "Required", controller: _titleCtrl, maxLines: 1),
            const SizedBox(height: 16),
            CustomTextField(labelText: "Project Description", hintText: "Enter description", errorMessage: "Required", controller: _descCtrl, maxLines: null, minLines: 5),
            const SizedBox(height: 16),
            CustomTextField(labelText: "Project Link (GitHub)", hintText: "Enter link", errorMessage: "Required", controller: _linkCtrl, maxLines: 1),
            const SizedBox(height: 16),
            CustomTextField(labelText: "Mentor Name", hintText: "Enter mentor name", errorMessage: "Required", controller: _mentorCtrl, maxLines: 1),
            const SizedBox(height: 16),
            CustomTextField(
              labelText: "Number of Members",
              hintText: "Enter number",
              errorMessage: "Required",
              controller: _membersNoCtrl,
              maxLines: 1,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            CustomTextField(labelText: "Members name", hintText: "Enter names", errorMessage: "Required", controller: _membersNameCtrl),
            const SizedBox(height: 16),
            CustomTextField(labelText: "Project Category", hintText: "AI, ML, Web, …", errorMessage: "Required", controller: _categoryCtrl),
            const SizedBox(height: 16),
            CustomTextField(
              labelText: "Year",
              hintText: "1‑4",
              errorMessage: "Required",
              controller: _yearCtrl,
              maxLines: 1,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            // ---------- Photos ----------
            const Text("Project Photo (first one required)", style: TextStyle(fontWeight: FontWeight.bold)),
            PhotoBox(key: _projPhotoKey, boxCount: 4, onChanged: (_) {}),
            const SizedBox(height: 16),

            const Text("Members Photo", style: TextStyle(fontWeight: FontWeight.bold)),
            PhotoBox(key: _memPhotoKey, boxCount: 4, onChanged: (_) {}),
            const SizedBox(height: 16),

            // ---------- Files ----------
            VideoUploadBox(key: _videoKey, label: 'Project Video', onVideoPicked: (_) {}),
            const SizedBox(height: 16),

            FileUploadBox(key: _pptKey, label: 'Project PPT', onFilePicked: (_) {}),
            const SizedBox(height: 8),

            FileUploadBox(key: _pdfKey, label: 'Project Report (PDF)', onFilePicked: (_) {}),
            const SizedBox(height: 24),

            // ---------- Submit ----------
            ElevatedButton.icon(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF77D8E),
                minimumSize: const Size(double.infinity, 56),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
              ),
              icon: const Icon(CupertinoIcons.arrow_right, color: Color(0xFFFE0037)),
              label: const Text('Submit', style: TextStyle(fontSize: 18)),
            ),

            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('OR', style: TextStyle(color: Colors.black26))),
                Expanded(child: Divider()),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'See All Projects',
                        style: const TextStyle(color: Colors.blue, fontSize: 18),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BottomNavBar())),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}