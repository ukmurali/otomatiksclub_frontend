import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stem_club/api/image_service/api_image_service.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:stem_club/utils/utils.dart';

class CustomCard extends StatefulWidget {
  const CustomCard({
    super.key,
    this.username,
    required this.title,
    this.description,
    required this.mediaUrl,
    this.isImage = true,
    this.postedOn,
  });

  final String? description;
  final String title;
  final bool isImage; // True if mediaUrl is an image, false if video
  final String mediaUrl; // URL of the image or video
  final String? username;
  final String? postedOn;

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  bool isFavorited = false; // Track the favorite state
  bool isLiked = false;
  int likeCount = 0;
  final DefaultCacheManager cacheManager = DefaultCacheManager();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              widget.title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
          ),
          const SizedBox(height: 8.0),

          // Media (Image or Video)
          widget.isImage
              ? AspectRatio(
                  aspectRatio: 1, // Maintain a 1:1 aspect ratio
                  child: FutureBuilder<Uint8List?>(
                    future: ApiImageService.fetchImage(widget.mediaUrl),
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
                )
              : Container(
                  height: 200.0,
                  color: Colors.black,
                  child: const Center(
                    child: Icon(Icons.play_circle_outline,
                        color: Colors.white, size: 50.0),
                  ),
                ),
          const SizedBox(height: 8.0),
          // Username
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15.0,
                    backgroundColor: Colors.grey,
                    child: Text(
                      getInitials(widget.username ?? 'NA'),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                  const SizedBox(
                      width: 8.0), // Space between avatar and username
                  Expanded(
                    child: Text(
                      widget.username ?? 'NA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                      overflow: TextOverflow.ellipsis, // Handles long usernames
                    ),
                  ),
                  const Spacer(), // Pushes `postedOn` to the right
                  Padding(
                    padding: const EdgeInsets.only(
                        right:
                            4.0), // Adjust right padding to move it slightly left
                    child: Text(
                      widget.postedOn ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 12.0,
                        color: Colors
                            .grey, // Optional to distinguish postedOn text
                      ),
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 8.0),

          // Like Count, Like Button, and Favorite Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
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
          ),
        ],
      ),
    );
  }
}
