import 'package:flutter/material.dart';
import 'package:stem_club/colors/app_colors.dart';
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
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = widget.controller.value.position;
    final totalDuration = widget.controller.value.duration;

    // Handle cases where the totalDuration might not be initialized yet
    final durationInSeconds =
        totalDuration != null && totalDuration.inSeconds > 0
            ? totalDuration.inSeconds.toDouble()
            : 0.0;

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
        // Display the current time, seekbar, and total duration
        Positioned(
          bottom: 0,
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
              // Seekbar to allow seeking the video
              SizedBox(
                width: double.infinity, // Slider will take up all available width
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6.0, // Increase thickness
                  ),
                  child: Slider(
                    value: currentPosition.inSeconds.toDouble().clamp(0.0, durationInSeconds),
                    min: 0.0,
                    max: durationInSeconds,
                    onChanged: (value) {
                      widget.controller.seekTo(Duration(seconds: value.toInt()));
                    },
                    activeColor: AppColors.primaryColor, // Customize active color
                    inactiveColor: Colors.white, // Customize inactive color
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
