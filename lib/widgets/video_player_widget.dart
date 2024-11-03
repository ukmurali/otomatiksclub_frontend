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
  final bool isGrid;
  final String mediaType;

  const VideoPlayerWidget({super.key, required this.mediaUrl, this.isGrid = false, this.mediaType = "drive"});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoController; // Nullable VideoPlayerController
  Future<void>? _initializeVideoPlayerFuture;
  bool isMuted = true;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayerFuture = _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      if (widget.mediaType == 'instagram') {
        // Initialize VideoPlayerController with network URL for Instagram
        _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl));
      } else {
        // Fetch video data for other sources (like Google Drive)
        Uint8List? videoData = await ApiImageService.fetchImage(widget.mediaUrl);
        if (videoData != null) {
          Directory tempDir = await getTemporaryDirectory();
          String videoPath = '${tempDir.path}/downloaded_video.mp4';
          File videoFile = File(videoPath);
          await videoFile.writeAsBytes(videoData);
          _videoController = VideoPlayerController.file(videoFile);
        } else {
          throw Exception("Failed to download video");
        }
      }

      // Check if _videoController was initialized successfully
      if (_videoController != null) {
        // Add error listener
        _videoController!.addListener(() {
          if (_videoController!.value.hasError) {
            debugPrint('Video playback error: ${_videoController!.value.errorDescription}');
          }
        });

        // Initialize the video player controller
        await _videoController!.initialize();
        _videoController!.setLooping(true);
        _videoController!.setVolume(0.0); // Mute the video by default

        setState(() {}); // Trigger a rebuild to reflect changes
      } else {
        throw Exception("VideoController is null");
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  bool isInstagramUrl(String url) {
    // Basic check for Instagram video URL
    return url.contains('instagram.com') && (url.endsWith('.mp4') || url.endsWith('/'));
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
      _videoController?.setVolume(isMuted ? 0.0 : 1.0);
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
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
                if (_videoController != null) VideoPlayer(_videoController!) else const SizedBox.shrink(),
                if (_videoController != null && !widget.isGrid) ControlsOverlay(controller: _videoController!),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(
                      isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    ),
                    onPressed: _toggleMute,
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
