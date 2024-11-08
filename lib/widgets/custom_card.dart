import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:otomatiksclub/api/favorite_service/api_favorite_service.dart';
import 'package:otomatiksclub/api/image_service/api_image_service.dart';
import 'package:otomatiksclub/api/post_like_service/api_post_like_service.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:otomatiksclub/screens/post_details_page.dart';
import 'package:otomatiksclub/utils/utils.dart';
import 'package:otomatiksclub/widgets/video_player_widget.dart';

class CustomCard extends StatefulWidget {
  const CustomCard({
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
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> with TickerProviderStateMixin {
  final DefaultCacheManager cacheManager = DefaultCacheManager();
  bool isFavorited = false; // Track the favorite state
  bool isLiked = false;
  int likeCount = 0;

  late Animation<double> _animationForFavorite;
  late Animation<double> _animationForLike;
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
    _animationForFavorite = getAnimation(_controllerForFavorite);
    _controllerForLike = getAnimationController();
    _animationForLike = getAnimation(_controllerForLike);
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
                : VideoPlayerWidget(mediaUrl: widget.mediaUrl),
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
          const SizedBox(height: 4.0),

          if (widget.approve)
            // Like Count, Like Button, and Favorite Button
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Row(
                children: [
                  // Favorite button
                  if (widget.currentUsername != widget.username)
                    IconButton(
                      icon: AnimatedBuilder(
                        animation: _animationForFavorite,
                        builder: (context, child) {
                          return Transform.scale(
                            scale:
                                isFavorited ? _animationForFavorite.value : 1.0,
                            child: Icon(
                              isFavorited || widget.isMyFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.currentUsername == widget.username
                                  ? Colors.grey // Disabled color
                                  : isFavorited || widget.isMyFavorite
                                      ? Colors.red
                                      : Colors.black, // Enabled colors
                            ),
                          );
                        },
                      ),
                      onPressed: widget.currentUsername == widget.username
                          ? null // Disable button if the current user is the author
                          : toggleFavorite,
                    ),
                  const Spacer(),
                  // Like button
                  if (widget.currentUsername != widget.username)
                    IconButton(
                      icon: AnimatedBuilder(
                        animation: _animationForLike,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isLiked ? _animationForLike.value : 1.0,
                            child: Icon(
                              isLiked
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              color: isLiked
                                  ? AppColors.primaryColor
                                  : Colors.black, // Enabled colors
                            ),
                          );
                        },
                      ),
                      onPressed: widget.currentUsername == widget.username
                          ? null // Disable button if the current user is the author
                          : toggleLike,
                    ),
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
                    'Waiting for Approval',
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
