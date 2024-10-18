import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;

  const ControlsOverlay({super.key, required this.controller});

  @override
  _ControlsOverlayState createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<ControlsOverlay> {
  @override
  void initState() {
    super.initState();
    // Add a listener to update the UI when the video state changes
    widget.controller.addListener(_updateState);
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    // Call setState to rebuild the widget when the controller state changes
    setState(() {});
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    Duration currentPosition = widget.controller.value.position;
    Duration totalDuration = widget.controller.value.duration;

    return Stack(
      children: <Widget>[
        // GestureDetector will toggle play/pause when tapped.
        GestureDetector(
          onTap: () {
            if (widget.controller.value.isPlaying) {
              widget.controller.pause();
            } else {
              widget.controller.play();
            }
          },
          child: Center(
            child: AnimatedOpacity(
              opacity: widget.controller.value.isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                // Show pause icon when playing and play icon otherwise
                widget.controller.value.isPlaying
                    ? Icons.pause // Pause icon
                    : Icons.play_arrow, // Play icon
                color: Colors.white, // Set the icon color to black
                size: 80.0, // Large size to make it noticeable
              ),
            ),
          ),
        ),
        // Display the current time and total duration
        Positioned(
          bottom: 30,
          left: 16,
          right: 16,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(currentPosition),
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    _formatDuration(totalDuration),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              // Optionally, you can add a Slider here to allow seeking
              Slider(
                value: currentPosition.inSeconds.toDouble(),
                min: 0,
                max: totalDuration.inSeconds.toDouble(),
                onChanged: (value) {
                  widget.controller.seekTo(Duration(seconds: value.toInt()));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
