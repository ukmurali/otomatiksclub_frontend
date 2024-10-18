import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:stem_club/utils/android_version_helper.dart';
import 'package:stem_club/widgets/controls_overlay.dart';
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
    int androidVersion = await AndroidVersionHelper.getAndroidSdkVersion();

    // Request permission based on media source
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        _showPermissionDeniedDialog('Camera');
        return;
      }
    } else if (source == ImageSource.gallery) {
      status = androidVersion >= 30
          ? await Permission.manageExternalStorage.request()
          : await Permission.storage.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        _showPermissionDeniedDialog('Gallery');
        return;
      }
    }

    try {
      // Separate logic for picking images and videos
      if (source == ImageSource.camera || source == ImageSource.gallery) {
        var pickedFile =
            await picker.pickImage(source: source, imageQuality: 100);
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            imageBytes = bytes;
            _videoController?.dispose();
            _videoController = null;
          });
        } else {
          // Pick video if no image was picked
          var pickedVideo = await picker.pickVideo(source: source);
          if (pickedVideo != null) {
            _videoController =
                VideoPlayerController.file(File(pickedVideo.path))
                  ..initialize().then((_) {
                    setState(() {
                      _videoController!.play(); // Start playing the video
                    });
                  });
          }
        }
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _resetMedia();
            // Close the dialog
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Add right padding
            child: ElevatedButton(
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
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // Wrap in SingleChildScrollView
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
                        maxLines: null, // Allow multiple lines
                        showCounter: false,
                      ),
                      const SizedBox(height: 16),
                      if (imageBytes != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              5.0), // Set corner radius here
                          child: Image.memory(
                            imageBytes!,
                            height: 500,
                            fit: BoxFit.fill,
                          ),
                        ),
                      if (_videoController != null &&
                          _videoController!.value.isInitialized)
                        Column(
                          children: [
                            AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  VideoPlayer(_videoController!),
                                  ControlsOverlay(
                                      controller: _videoController!),
                                  VideoProgressIndicator(_videoController!,
                                      allowScrubbing: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.black),
                    onPressed: () {
                      // Handle send action
                      _pickMedia(ImageSource.camera);
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.photo_library, color: Colors.black),
                    onPressed: () {
                      _pickMedia(ImageSource.gallery);
                    },
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
