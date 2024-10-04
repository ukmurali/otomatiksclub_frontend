// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:stem_club/utils/utils.dart';
import 'package:stem_club/widgets/custom_text_form_field.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';

class CreatePostDialogWeb extends StatefulWidget {
  const CreatePostDialogWeb({super.key});

  @override
  _CreatePostDialogWebState createState() => _CreatePostDialogWebState();
}

class _CreatePostDialogWebState extends State<CreatePostDialogWeb> {
  final ImagePicker picker = ImagePicker();
  PlatformFile? pickedFile;
  VideoPlayerController? _videoController;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  Uint8List? webImage;
  String? _videoUrl;
  html.VideoElement? _videoElement;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _videoElement = html.VideoElement()
        ..style.height = '100%'
        ..style.width = '100%'
        ..controls = true
        ..autoplay = false;

      ui_web.platformViewRegistry.registerViewFactory(
        'videoPlayer',
        (int viewId) => _videoElement!,
      );
    }
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'mp4'],
      );

      if (result == null) return;

      final file = result.files.single;
      final String fileName = file.name.toLowerCase();

      if (fileName.endsWith('.png') ||
          fileName.endsWith('.jpg') ||
          fileName.endsWith('.jpeg') ||
          fileName.endsWith('.mp4')) {
        if (fileName.endsWith('.mp4')) {
          if (_videoUrl != null) {
            html.Url.revokeObjectUrl(_videoUrl!);
          }

          final blob = html.Blob([file.bytes!]);
          final blobUrl = html.Url.createObjectUrlFromBlob(blob);

          setState(() {
            _videoUrl = blobUrl;
            pickedFile = null;
            webImage = null;
            _initializeVideoElement(blobUrl);
          });
        } else {
          final bytes = file.bytes!;
          setState(() {
            _resetMedia();
            webImage = bytes;
          });
        }
      } else {
        showErrorDialog(context,
            'Unsupported file type. Please select a PNG, JPG, JPEG image, or MP4 video.');
      }
    } catch (e) {
      showErrorDialog(context, 'Error picking media: $e');
    }
  }

  void _initializeVideoElement(String blobUrl) {
    if (_videoElement != null) {
      _videoElement!.src = blobUrl;
      _videoElement!.load();
    }
  }

  void _resetMedia() {
    if (_videoUrl != null) {
      html.Url.revokeObjectUrl(_videoUrl!);
    }

    if (mounted) {
      setState(() {
        _videoUrl = null;
        webImage = null;
        pickedFile = null;

        if (_videoElement != null) {
          _videoElement!.src = '';
          _videoElement!.load();
        }

        _videoController?.dispose();
        _videoController = null;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _resetMedia();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const isWeb = kIsWeb;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.8;

    return AlertDialog(
      title: const Text('Create Post'),
      content: SizedBox(
        width: isWeb ? 700 : null,
        height: dialogHeight,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              GestureDetector(
                child: Container(
                  width: double.infinity,
                  height: isWeb ? 300 : dialogHeight * 0.4,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _videoUrl != null
                        ? (isWeb
                            ? const HtmlElementView(viewType: 'videoPlayer')
                            : (_videoController != null &&
                                    _videoController!.value.isInitialized
                                ? AspectRatio(
                                    aspectRatio: _videoController!.value.aspectRatio,
                                    child: VideoPlayer(_videoController!),
                                  )
                                : const CircularProgressIndicator()))
                        : webImage != null
                            ? Image.memory(
                                webImage!,
                                fit: BoxFit.cover,
                              )
                            : pickedFile != null
                                ? Image.file(
                                    File(pickedFile!.path!),
                                    fit: BoxFit.cover,
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.photo_size_select_actual_outlined,
                                          size: 50, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(
                                        'Select image or a video',
                                        style: TextStyle(color: Colors.grey, fontSize: 16),
                                      ),
                                    ],
                                  ),
                  ),
                ),
                onTap: () {
                  // Optional: Add functionality to preview or interact with the media
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _pickMedia(ImageSource.gallery);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                ),
                icon: const Icon(Icons.photo_library),
                label: const Text('Select Media from Computer'),
              ),
              if (!isWeb)
                ElevatedButton.icon(
                  onPressed: () {
                    _pickMedia(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Capture Image or Video'),
                ),
            ],
          ),
        ),
      ),
      actions: [
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
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'file': pickedFile,
              'title': titleController.text,
              'description': descriptionController.text,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.textColor,
          ),
          child: const Text('Post'),
        ),
      ],
    );
  }
}
