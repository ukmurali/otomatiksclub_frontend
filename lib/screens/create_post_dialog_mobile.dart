import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otomatiksclub/api/user_service/api_user_service.dart';
import 'package:otomatiksclub/model/user.dart';
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
import 'dart:developer' as developer;

class CreatePostDialogMobile extends StatefulWidget {
  const CreatePostDialogMobile(
      {super.key,
      this.role,
      this.postId,
      this.title,
      this.description,
      this.mediaUrl,
      this.isImage = true});

  final String? description;
  final String? mediaUrl;
  final String? postId;
  final String? title;
  final bool isImage;
  final String? role;

  @override
  _CreatePostDialogMobileState createState() => _CreatePostDialogMobileState();
}

class _CreatePostDialogMobileState extends State<CreatePostDialogMobile> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  List<User> suggestions = [];
  User? selectedUser;
  Timer? _debounce;
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
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<List<User>> fetchSuggestions(String query) async {
    try {
      if (query.isEmpty) {
        return []; // Return an empty list if query is empty
      }
      setState(() => _isLoading = true);
      final response = await ApiUserService.searchUsers(query);
      setState(() => _isLoading = false);
      if (response != null && response['statusCode'] == 200) {
        final data = jsonDecode(response['body']) as List;
        // Parse the user objects from the response
        return data.map((userJson) => User.fromJson(userJson)).toList();
      } else {
        developer.log('Failed to fetch suggestions: ${response?['body']}');
        return [];
      }
    } catch (e) {
      setState(() => _isLoading = false);
      developer.log('Error fetching suggestions: $e');
      return [];
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length >= 3) {
        final userSuggestions = await fetchSuggestions(query);
        setState(() {
          suggestions = userSuggestions;
        });
      } else {
        setState(() {
          suggestions = [];
        });
      }
    });
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

  Future<void> _pickMediaForMobile(ImageSource source) async {
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

  // Future<void> _pickMediaForWeb() async {
  //   // Create a file input element
  //   final html.FileUploadInputElement uploadInput =
  //       html.FileUploadInputElement();
  //   uploadInput.accept = 'image/*,video/*'; // Allow images and videos
  //   uploadInput.click(); // Simulate a click to open file picker

  //   uploadInput.onChange.listen((e) async {
  //     final files = uploadInput.files;
  //     if (files != null && files.isNotEmpty) {
  //       final reader = html.FileReader();

  //       reader.onLoadEnd.listen((e) {
  //         setState(() {
  //           if (files.first.type.startsWith('image/')) {
  //             postType = AppConstants.image;
  //             imageBytes = reader.result as Uint8List; // Load image bytes
  //             _pickedImagePath = files.first.name; // Store image file name
  //             // Dispose of any existing video controller
  //             if (_videoController != null) {
  //               _videoController!.dispose();
  //               _videoController = null;
  //             }
  //           } else if (files.first.type.startsWith('video/')) {
  //             postType = AppConstants.video;
  //             _pickedVideoPath = files.first.name; // Store video file name
  //             // Clear image bytes
  //             imageBytes = null;
  //             // Initialize the video controller for the picked video (Web playback may require a URL)
  //           }
  //         });
  //       });

  //       // Read file as bytes
  //       reader.readAsArrayBuffer(files.first);
  //     }
  //   });
  // }

  Future<void> _pickMedia(ImageSource source) async {
    // if (kIsWeb) {
    //   await _pickMediaForWeb(); // Handle web-specific media picking
    //   return;
    // }
    // Handle mobile-specific media picking
    await _pickMediaForMobile(source);
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

  String? _validateStudentField({required String? value}) {
    if (value == null || value.isEmpty) {
      return 'Please enter student name';
    }
    if (selectedUser == null) {
      return 'Please select valid student name';
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
      } else {
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
      final response = await ApiPostService.createPost(
          uploadFile, formData, isVideoType, fileId, selectedUser);
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

  Widget _buildSearchWithSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          controller: searchController,
          labelText: 'Search Student',
          keyboardType: TextInputType.name,
          readOnly: false,
          showCounter: false,
          onChanged: onSearchChanged,
          validator: (value) => _validateStudentField(value: value),
        ),
        const SizedBox(height: 8),
        if (suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final user = suggestions[index];
                return ListTile(
                  title: Text(user.username),
                  onTap: () {
                    searchController.text = user.username;
                    setState(() {
                      selectedUser = user;
                      suggestions = [];
                    });
                  },
                );
              },
            ),
          ),
        const SizedBox(height: 16),
      ],
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
                                  if (widget.role != 'STUDENT')
                                    _buildSearchWithSuggestions(),
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
                                _videoController == null &&
                                !widget.isImage)
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
                        if (!kIsWeb)
                          IconButton(
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.black),
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
