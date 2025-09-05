import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Needed for Image.file
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
  String? _mediaType;

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
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text("Missing Info"),
          content: const Text("Please add a description or media"),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    print("📍 Location: ${widget.latitude}, ${widget.longitude}");
    print("📝 Description: $description");
    if (_mediaFile != null) {
      print("📂 Media: ${_mediaFile!.path} (type: $_mediaType)");
    }

    // Show success dialog, then pop back to map
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Success"),
        content: const Text("Report submitted!"),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(
                  context); // close ReportScreen -> back to CampusMapScreen
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Report Danger"),
        backgroundColor: CupertinoColors.destructiveRed,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Location: (${widget.latitude.toStringAsFixed(5)}, ${widget.longitude.toStringAsFixed(5)})",
                style: const TextStyle(
                    fontSize: 14, color: CupertinoColors.systemGrey),
              ),
              const SizedBox(height: 20),

              CupertinoTextField(
                controller: _descriptionController,
                placeholder: "Describe the danger",
                maxLines: 3,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 20),

              // Media preview with remove button
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _mediaFile != null
                    ? Stack(
                        alignment: Alignment.topRight,
                        children: [
                          _mediaType == "image"
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _mediaFile!,
                                    height: 150,
                                    key: ValueKey(_mediaFile!.path),
                                  ),
                                )
                              : Icon(
                                  CupertinoIcons.videocam_fill,
                                  size: 100,
                                  color: CupertinoColors.activeBlue,
                                  key: ValueKey(_mediaFile!.path),
                                ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _mediaFile = null;
                                  _mediaType = null;
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: CupertinoColors.systemGrey,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  CupertinoIcons.clear,
                                  size: 18,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: const [
                        Icon(CupertinoIcons.photo),
                        SizedBox(width: 6),
                        Text("Add Photo"),
                      ],
                    ),
                    onPressed: _pickImage,
                  ),
                  CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: const [
                        Icon(CupertinoIcons.videocam),
                        SizedBox(width: 6),
                        Text("Add Video"),
                      ],
                    ),
                    onPressed: _pickVideo,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Centered Submit Button with white text
              Center(
                child: CupertinoButton(
                  color: CupertinoColors.systemRed,
                  borderRadius: BorderRadius.circular(30),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                  child: const Text(
                    "Submit Report",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                  onPressed: _submitReport,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
