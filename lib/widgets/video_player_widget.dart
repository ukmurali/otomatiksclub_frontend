import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stem_club/api/image_service/api_image_service.dart';
import 'package:stem_club/widgets/controls_overlay.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String mediaUrl;

  const VideoPlayerWidget({super.key, required this.mediaUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayerFuture = _downloadAndInitializeVideo();
  }

  Future<void> _downloadAndInitializeVideo() async {
    try {
      // Fetch video data
      Uint8List? videoData = await ApiImageService.fetchImage(widget.mediaUrl);

      if (videoData != null) {
        // Get the temporary directory to save the video
        Directory tempDir = await getTemporaryDirectory();
        String videoPath = '${tempDir.path}/downloaded_video.mp4';

        // Write the video data to a file
        File videoFile = File(videoPath);
        await videoFile.writeAsBytes(videoData);

        // Initialize the video player controller
        _videoController = VideoPlayerController.file(videoFile);
        await _videoController.initialize();
        _videoController.setLooping(true);

        setState(() {
          _initializeVideoPlayerFuture = _videoController.initialize();
        });
      } else {
        throw Exception("Failed to download video");
      }
    } catch (e) {
      debugPrint('Error downloading or initializing video: $e');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.8, // Maintain a 1:1 aspect ratio
      child: FutureBuilder<void>(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                color: Colors.grey[300],
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading video'),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(_videoController),
                ControlsOverlay(controller: _videoController),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
