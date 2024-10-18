import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const ControlsOverlay({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // This GestureDetector will toggle play/pause when the user taps the video.
        GestureDetector(
          onTap: () {
            if (controller.value.isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
          },
          // Ensure the icons are centered and always visible when paused.
          child: Center(
            child: AnimatedOpacity(
              opacity: controller.value.isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              // Icon size is large and in white for contrast.
              child: Icon(
                controller.value.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: Colors.white, // Make sure the icon is clearly visible
                size: 80.0, // Large size to make it noticeable
              ),
            ),
          ),
        ),
      ],
    );
  }
}