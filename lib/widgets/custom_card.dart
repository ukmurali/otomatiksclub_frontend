import 'package:flutter/material.dart';
import 'package:stem_club/colors/app_colors.dart';

class CustomCard extends StatefulWidget {
  final String? username;
  final String description;
  final String mediaUrl; // URL of the image or video
  final bool isImage; // True if mediaUrl is an image, false if video

  const CustomCard({
    super.key,
    this.username,
    required this.description,
    required this.mediaUrl,
    this.isImage = true,
  });

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  bool isLiked = false;
  bool isFavorited = false; // Track the favorite state
  int likeCount = 0;

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  void toggleFavorite() {
    setState(() {
      isFavorited = !isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      color: Colors.white,
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(
              widget.description,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),

            // Media (Image or Video)
            widget.isImage
                ? Image.network(widget.mediaUrl, fit: BoxFit.cover)
                : Container(
                    height: 200.0,
                    color: Colors.black,
                    child: const Center(
                      child: Icon(Icons.play_circle_outline, color: Colors.white, size: 50.0),
                    ),
                  ),
            const SizedBox(height: 8.0),

            // Username
            Text(
              widget.username ?? 'NA',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            const SizedBox(height: 8.0),

            // Like Count, Like Button, and Favorite Button
            Row(
              children: [
                Text(
                  '$likeCount Likes',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: isLiked ? AppColors.primaryColor : Colors.black,
                  ),
                  onPressed: toggleLike,
                ),
                IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.black,
                  ),
                  onPressed: toggleFavorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}