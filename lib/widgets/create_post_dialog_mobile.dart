import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:stem_club/utils/android_version_helper.dart';
import 'package:stem_club/widgets/controls_overlay.dart';
import 'package:stem_club/widgets/custom_snack_bar.dart';
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

  String? titleError;
  String? descriptionError;

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
      var pickedFile =
          await picker.pickImage(source: source, imageQuality: 100);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          imageBytes = bytes;
          // Dispose of the old video controller if a video was previously selected
          if (_videoController != null) {
            _videoController!.dispose();
            _videoController = null; // Clear the video controller
          }
        });
      } else {
        // Pick video if no image was picked
        var pickedVideo = await picker.pickVideo(source: source);
        if (pickedVideo != null) {
          // Dispose of the old video controller before initializing a new one
          if (_videoController != null) {
            await _videoController!.dispose();
          }
          setState(() {
            imageBytes = null; // Clear image when a video is selected
            _videoController =
                VideoPlayerController.file(File(pickedVideo.path))
                  ..initialize().then((_) {
                    setState(() {}); // Rebuild the UI when the video is ready
                  });

            // Ensure that the seek bar and player state are properly managed
            _videoController!.addListener(() {
              setState(() {}); // Update the UI every time video state changes
            });
          });
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

  void _resetMedia() {
    setState(() {
      imageBytes = null;
      _videoController?.dispose();
      _videoController = null;
    });
  }

  void _validateAndPost() {
    if (titleController.text.isEmpty) {
      CustomSnackbar.showSnackBar(context, 'Title is required', false);
    } else if (descriptionController.text.isEmpty) {
      CustomSnackbar.showSnackBar(context, 'Description is required', false);
    } else if ((imageBytes == null && _videoController == null)) {
      CustomSnackbar.showSnackBar(
          context, 'Please select an image or video.', false);
    }
  }

  @override
  void dispose() {
    _resetMedia(); // Make sure media is reset on dispose
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
            _resetMedia(); // Reset the media on close
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: _validateAndPost,
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
                        maxLines: null,
                        showCounter: false,
                      ),
                      const SizedBox(height: 16),
                      if (imageBytes != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: Image.memory(
                            imageBytes!,
                            height: 500,
                            fit: BoxFit.fill,
                          ),
                        ),
                      if (_videoController != null &&
                          _videoController!.value.isInitialized)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: Column(
                            children: [
                              SizedBox(
                                width: screenWidth,
                                height:
                                    500, // Desired height for the video player
                                child: AspectRatio(
                                  aspectRatio:
                                      _videoController!.value.aspectRatio,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      VideoPlayer(_videoController!),
                                      ControlsOverlay(
                                          controller: _videoController!),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
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
