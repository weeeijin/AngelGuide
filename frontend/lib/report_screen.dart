import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReportScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const ReportScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _mediaFile;
  String? _mediaType; // "image" or "video"

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _mediaType = "image";
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? pickedFile =
        await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _mediaType = "video";
      });
    }
  }

  void _submitReport() {
    final description = _descriptionController.text;

    if (description.isEmpty && _mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a description or media")),
      );
      return;
    }

    // For now, just print the data
    print("📍 Location: ${widget.latitude}, ${widget.longitude}");
    print("📝 Description: $description");
    if (_mediaFile != null) {
      print("📂 Media: ${_mediaFile!.path} (type: $_mediaType)");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Report submitted!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Danger"),
        backgroundColor: Colors.red,
      ),
      resizeToAvoidBottomInset: true, // let scaffold adjust
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ), // <-- dynamic bottom padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Location: (${widget.latitude.toStringAsFixed(5)}, ${widget.longitude.toStringAsFixed(5)})",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Text input
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Describe the danger",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Media preview
            if (_mediaFile != null)
              _mediaType == "image"
                  ? Image.file(_mediaFile!, height: 150)
                  : const Icon(Icons.videocam, size: 100, color: Colors.blue),

            const SizedBox(height: 10),

            // Buttons to pick media
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text("Add Photo"),
                  onPressed: _pickImage,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.videocam),
                  label: const Text("Add Video"),
                  onPressed: _pickVideo,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Submit button (already curved ✅)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _submitReport,
              child: const Text(
                "Submit Report",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
