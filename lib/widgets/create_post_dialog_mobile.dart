import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:stem_club/widgets/custom_text_form_field.dart';
import 'package:video_player/video_player.dart';

class CreatePostDialogMobile extends StatefulWidget {
  const CreatePostDialogMobile({super.key});

  @override
  _CreatePostDialogMobileState createState() => _CreatePostDialogMobileState();
}

class _CreatePostDialogMobileState extends State<CreatePostDialogMobile> {
  final ImagePicker picker = ImagePicker();
  VideoPlayerController? _videoController;
  Uint8List? imageBytes;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> _pickMedia(ImageSource source) async {
    PermissionStatus status;

    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
      if (status.isDenied) {
        _showPermissionDeniedDialog('Camera');
        return;
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog('Camera');
        return;
      }
    } else if (source == ImageSource.gallery) {
      status = await Permission.storage.request();
      if (status.isDenied) {
        _showPermissionDeniedDialog('Gallery');
        return;
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog('Gallery');
        return;
      }
    }

    try {
      var pickedFile =
          await picker.pickImage(source: source, imageQuality: 100) ??
              await picker.pickVideo(source: source);

      if (pickedFile == null) return;

      final fileName = pickedFile.name.toLowerCase();

      if (fileName.endsWith('.mp4')) {
        if (_videoController != null) {
          _videoController?.dispose();
        }
        _videoController = VideoPlayerController.file(File(pickedFile.path))
          ..initialize().then((_) {
            setState(() {});
          });
      } else {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          imageBytes = bytes;
          _videoController?.dispose();
          _videoController = null;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _showPermissionDeniedDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission Denied'),
        content: Text(
            'Please enable $permissionName permission in settings to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission Permanently Denied'),
        content: Text(
            'This app requires $permissionName permission to continue. Please go to the app settings to enable it.'),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _resetMedia() {
    setState(() {
      imageBytes = null;
      _videoController?.dispose();
      _videoController = null;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _resetMedia();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Create Post',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _resetMedia();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: titleController,
                      labelText: 'Title',
                      keyboardType: TextInputType.name,
                      readOnly: false,
                      showCounter: false,
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: descriptionController,
                      labelText: 'Description',
                      keyboardType: TextInputType.multiline,
                      readOnly: false,
                      showCounter: false,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickMedia(ImageSource.camera),
                          icon: const Icon(
                            Icons.camera_alt,
                            color: AppColors.primaryColor,
                          ),
                          label: const Text(
                            'Camera',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickMedia(ImageSource.gallery),
                          icon: const Icon(
                            Icons.photo_library,
                            color: AppColors.primaryColor,
                          ),
                          label: const Text(
                            'Gallery',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (imageBytes != null)
                      Image.memory(
                        imageBytes!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    if (_videoController != null &&
                        _videoController!.value.isInitialized)
                      AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _resetMedia();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Handle post creation logic here
                      _resetMedia();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.textColor,
                    ),
                    child: const Text('Post'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
