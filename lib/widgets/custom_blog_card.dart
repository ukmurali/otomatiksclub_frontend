import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:otomatiksclub/api/image_service/api_image_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:otomatiksclub/screens/post_details_page.dart';
import 'package:otomatiksclub/utils/utils.dart';
import 'package:otomatiksclub/widgets/video_player_widget.dart';

class CustomBlogCard extends StatefulWidget {
  const CustomBlogCard({
    super.key,
    this.blogId,
    this.username,
    required this.title,
    this.description,
    required this.mediaUrl,
    this.isImage = true,
    this.postedOn,
    required this.currentUsername,
    required this.role,
  });

  final String currentUsername;
  final String? description;
  final bool isImage; // True if mediaUrl is an image, false if video
  final String mediaUrl; // URL of the image or video
  final String? blogId;
  final String? postedOn;
  final String title;
  final String? username;
  final String role;

  @override
  _CustomBlogCardState createState() => _CustomBlogCardState();
}

class _CustomBlogCardState extends State<CustomBlogCard> with TickerProviderStateMixin {
  final DefaultCacheManager cacheManager = DefaultCacheManager();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            3.0), // Adjust the value for desired corner radius
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with menu button
          Padding(
            padding: const EdgeInsets.only(left: 7.0, right: 1.0, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  constraints: const BoxConstraints(
                      maxWidth: 200), // Adjust max width as needed
                  child: Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // Media (Image or Video) wrapped in GestureDetector
          GestureDetector(
            onTap: () {
              // Navigate to PostDetailPage when image/video is tapped
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => PostDetailPage(
                    postId: widget.blogId!,
                    title: widget.title,
                    description: widget.description ?? '',
                    imageUrl: widget.mediaUrl,
                    username: widget.username ?? '',
                    createdDate: widget.postedOn ?? '',
                    postStatus: "",
                    currentUsername: widget.currentUsername,
                    isImage: widget.isImage,
                    role: widget.role,
                    postAction: 'Blog',
                  ),
                ),
              );
            },
            // Media (Image or Video)
            child: widget.isImage
                ? AspectRatio(
                    aspectRatio: 1, // Maintain a 1:1 aspect ratio
                    child: FutureBuilder<Uint8List?>(
                      future: ApiImageService.fetchImage(widget.mediaUrl),
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
                            height: 40,
                            fit: BoxFit
                                .cover, // Make the image cover the entire width
                          );
                        }
                        return const SizedBox
                            .shrink(); // In case of any unforeseen state
                      },
                    ),
                  )
                : VideoPlayerWidget(mediaUrl: widget.mediaUrl),
          ),
          const SizedBox(height: 8.0),
          // Username
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
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
                const SizedBox(width: 8.0), // Space between avatar and username
                Expanded(
                  child: Text(
                    widget.currentUsername == widget.username
                        ? "You"
                        : widget.username ?? "NA",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                    overflow: TextOverflow
                        .ellipsis, // This truncates text with an ellipsis if it's too long
                  ),
                ),
                const Spacer(), // Pushes `postedOn` to the right
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    widget.postedOn ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12.0,
                      color:
                          Colors.grey, // Optional to distinguish postedOn text
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
