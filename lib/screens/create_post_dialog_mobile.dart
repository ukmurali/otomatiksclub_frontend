import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:otomatiksclub/api/image_service/api_image_service.dart';
import 'package:otomatiksclub/api/post_service/api_post_service.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/screens/dashboard.dart';
import 'package:otomatiksclub/utils/android_version_helper.dart';
import 'package:otomatiksclub/widgets/controls_overlay.dart';
import 'package:otomatiksclub/widgets/custom_snack_bar.dart';
import 'package:otomatiksclub/widgets/custom_text_form_field.dart';
import 'package:otomatiksclub/widgets/loading_indicator.dart';
import 'package:otomatiksclub/widgets/video_player_widget.dart';
import 'package:video_player/video_player.dart';

class CreatePostDialogMobile extends StatefulWidget {
  const CreatePostDialogMobile(
      {super.key, this.postId, this.title, this.description, this.mediaUrl, this.isImage = true});

  final String? description;
  final String? mediaUrl;
  final String? postId;
  final String? title;
  final bool isImage;

  @override
  _CreatePostDialogMobileState createState() => _CreatePostDialogMobileState();
}

class _CreatePostDialogMobileState extends State<CreatePostDialogMobile> {
  final TextEditingController descriptionController = TextEditingController();
  String? descriptionError;
  Uint8List? imageBytes;
  final ImagePicker picker = ImagePicker();
  String postType = AppConstants.image;
  final TextEditingController titleController = TextEditingController();
  String? titleError;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _pickedImagePath;
  String? _pickedVideoPath;
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    imageBytes = null;
    _videoController?.dispose();
    _videoController = null;
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Check if user data is available and populate the fields
    if (widget.title != null) {
      titleController.text = widget.title ?? '';
    }
    if (widget.description != null) {
      descriptionController.text = widget.description ?? '';
    }
  }

  Map<String, String> getFormData() {
    return {
      'title': titleController.text,
      'description': descriptionController.text,
      'postType': postType,
    };
  }

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
        _pickedImagePath = pickedFile.path;
        final bytes = await pickedFile.readAsBytes();
        postType = AppConstants.image;
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
          _pickedVideoPath = pickedVideo.path;
          postType = AppConstants.video;
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
    if (mounted) {
      setState(() {
        imageBytes = null;
        _videoController?.dispose();
        _videoController = null;
      });
    } else {
      // If already disposed, just clean up the video controller
      _videoController?.dispose();
      _videoController = null;
    }
  }

  String? _validateField({required String? value}) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Title';
    }
    return null;
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    String? fileId;
    if ((imageBytes == null &&
        _videoController == null &&
        widget.postId == null)) {
      setState(() => _isLoading = false);
      CustomSnackbar.showSnackBar(
          context, 'Please select an image or video.', false);
    } else {
      final formData = getFormData();
      if (widget.postId != null) {
        formData['postId'] = widget.postId ?? '';
        fileId = widget.mediaUrl;
      }
      else{
        fileId = null;
      }
      File? uploadFile;
      bool isVideoType = false;
      if (_pickedImagePath != null) {
        isVideoType = false;
        uploadFile = File(_pickedImagePath!);
      }
      if (_pickedVideoPath != null) {
        isVideoType = true;
        uploadFile = File(_pickedVideoPath!);
      }
      final response =
          await ApiPostService.createPost(uploadFile, formData, isVideoType, fileId);
      final responseBody = response['body'] as String;
      if (!mounted) return;
      setState(() => _isLoading = false);
      if ((response['statusCode'] != 201)) {
        CustomSnackbar.showSnackBar(context, responseBody, false);
        return;
      }
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    _resetMedia();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const DashboardPage(initialTabIndex: 1)),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: widget.title == null
            ? const Text('Create Post')
            : const Text('Edit Post'),
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
              onPressed: _savePost,
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
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isLoading,
            child: SizedBox(
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
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  CustomTextFormField(
                                    controller: titleController,
                                    labelText: 'Title',
                                    keyboardType: TextInputType.name,
                                    readOnly: false,
                                    showCounter: false,
                                    validator: (value) =>
                                        _validateField(value: value),
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
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (widget.title != null &&
                                imageBytes == null &&
                                widget.isImage)
                              AspectRatio(
                                aspectRatio: 1, // Maintain a 1:1 aspect ratio
                                child: FutureBuilder<Uint8List?>(
                                  future: ApiImageService.fetchImage(
                                      widget.mediaUrl),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: double.infinity,
                                          color: Colors.grey[300],
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      // Display default image on error
                                      return Image.asset(
                                        'assets/images/image1.png', // Path to your default image
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      );
                                    } else if (snapshot.hasData) {
                                      final imageBytes = snapshot.data!;
                                      return Image.memory(
                                        imageBytes,
                                        width: double.infinity,
                                        fit: BoxFit
                                            .cover, // Make the image cover the entire width
                                      );
                                    }
                                    return const SizedBox
                                        .shrink(); // In case of any unforeseen state
                                  },
                                ),
                              ),
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
                            if (widget.title != null &&
                                imageBytes == null &&
                                _videoController == null && !widget.isImage)
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: VideoPlayerWidget(
                                      mediaUrl: widget.mediaUrl!)),
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
                          icon:
                              const Icon(Icons.camera_alt, color: Colors.black),
                          onPressed: () {
                            _pickMedia(ImageSource.camera);
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.photo_library,
                              color: Colors.black),
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
          ),
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }
}
