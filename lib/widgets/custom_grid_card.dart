import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:otomatiksclub/api/favorite_service/api_favorite_service.dart';
import 'package:otomatiksclub/api/image_service/api_image_service.dart';
import 'package:otomatiksclub/api/post_like_service/api_post_like_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:otomatiksclub/screens/post_details_page.dart';
import 'package:otomatiksclub/widgets/video_player_widget.dart';

class CustomGridCard extends StatefulWidget {
  const CustomGridCard({
    super.key,
    this.postId,
    this.username,
    required this.title,
    this.description,
    required this.mediaUrl,
    this.isImage = true,
    this.postedOn,
    required this.currentUsername,
    this.approve = false,
    this.isFavorited = false,
    this.isLiked = false,
    this.onFavoriteToggle, // Callback for updating parent
    this.isMyFavorite = false,
    this.onLikeToggle,
    this.totalLikes = 0,
  });

  final bool approve;
  final String currentUsername;
  final String? description;
  final bool isFavorited;
  final bool isImage; // True if mediaUrl is an image, false if video
  final bool isLiked;
  final bool isMyFavorite;
  final String mediaUrl; // URL of the image or video
  final VoidCallback? onFavoriteToggle; // Callback added here
  final VoidCallback? onLikeToggle; // Callback added here
  final String? postId;
  final String? postedOn;
  final String title;
  final int totalLikes;
  final String? username;

  @override
  _CustomGridCardState createState() => _CustomGridCardState();
}

class _CustomGridCardState extends State<CustomGridCard>
    with TickerProviderStateMixin {
  final DefaultCacheManager cacheManager = DefaultCacheManager();
  bool isFavorited = false; // Track the favorite state
  bool isLiked = false;
  int likeCount = 0;

  late AnimationController _controllerForFavorite;
  late AnimationController _controllerForLike;

  @override
  void dispose() {
    _controllerForFavorite.dispose();
    _controllerForLike.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize AnimationController and Animation
    _controllerForFavorite = getAnimationController();
    _controllerForLike = getAnimationController();
    setState(() {
      isFavorited = widget.isFavorited;
      isLiked = widget.isLiked;
      likeCount = widget.totalLikes;
    });
  }

  AnimationController getAnimationController() {
    return AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  Animation<double> getAnimation(AnimationController controller) {
    return Tween<double>(begin: 1.0, end: 3).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    ));
  }

  void toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
      _controllerForLike.forward().then((_) => _controllerForLike.reverse());
    });
    if (isLiked) {
      await ApiPostLikeService.createPostLike(widget.postId!);
    } else {
      await ApiPostLikeService.removePostLike(widget.postId!);
    }
    // Notify parent to refresh the data if a callback is provided
    widget.onLikeToggle?.call();
  }

  Future<void> toggleFavorite() async {
    setState(() {
      isFavorited = !isFavorited;
      _controllerForFavorite
          .forward()
          .then((_) => _controllerForFavorite.reverse());
    });
    if (isFavorited) {
      await ApiFavoriteService.createFavorite(widget.postId!);
    } else {
      await ApiFavoriteService.removeFavorite(widget.postId!);
    }
    // Notify parent to refresh the data if a callback is provided
    widget.onFavoriteToggle?.call();
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
            padding: const EdgeInsets.only(left: 7.0, right: 1.0),
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
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Media (Image or Video) wrapped in GestureDetector
          GestureDetector(
            onTap: () {
              // Navigate to PostDetailPage when image/video is tapped
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => PostDetailPage(
                    postId: widget.postId!,
                    title: widget.title,
                    description: widget.description ?? '',
                    imageUrl: widget.mediaUrl,
                    username: widget.username ?? 'Unknown',
                    createdDate: widget.postedOn ?? '',
                    approve: widget.approve,
                    currentUsername: widget.currentUsername,
                    likeCount: likeCount,
                    isLiked: isLiked,
                    isFavorited: isFavorited,
                    isImage: widget.isImage,
                    onFavoriteToggle: (newFavoritedStatus) {
                      setState(() {
                        // Update the favorite status in the parent widget
                        isFavorited = newFavoritedStatus;
                      });
                      widget.onFavoriteToggle?.call();
                    },
                    onLikeToggle: (newLikeStatus) {
                      setState(() {
                        // Update the favorite status in the parent widget
                        isLiked = newLikeStatus;
                        if (isLiked) {
                          likeCount++;
                        } else {
                          likeCount--;
                        }
                      });
                      widget.onLikeToggle?.call();
                    },
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
                : VideoPlayerWidget(mediaUrl: widget.mediaUrl, isGrid: true),
          ),
          if (widget.approve)
            // Like Count, Like Button, and Favorite Button
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Row(
                children: [
                  const Spacer(),
                  // Like button

                  Text(
                    '$likeCount Likes',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            )
          else
            Container(
              color: Colors.orange, // Background color for the SizedBox
              child: const SizedBox(
                height: 25, // Height of the SizedBox
                child: Center(
                  child: Text(
                    'Pending Approval',
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontSize: 12,
                      fontWeight: FontWeight.bold, // Text size
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
