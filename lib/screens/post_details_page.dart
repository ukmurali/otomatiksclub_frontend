import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:otomatiksclub/api/favorite_service/api_favorite_service.dart';
import 'package:otomatiksclub/api/image_service/api_image_service.dart';
import 'package:otomatiksclub/api/post_like_service/api_post_like_service.dart';
import 'package:otomatiksclub/api/post_service/api_post_service.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/screens/create_post_dialog_mobile.dart';
import 'package:otomatiksclub/screens/dashboard.dart';
import 'package:otomatiksclub/widgets/custom_snack_bar.dart';
import 'package:otomatiksclub/widgets/video_player_widget.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  final String title;
  final String description;
  final String imageUrl;
  final String username;
  final String createdDate;
  final bool approve;
  final String currentUsername;
  final bool isFavorited;
  final bool isLiked;
  final int likeCount;
  final Function(bool)? onFavoriteToggle;
  final Function(bool)? onLikeToggle;
  final bool isImage;

  const PostDetailPage({
    super.key,
    required this.postId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.username,
    required this.createdDate,
    this.approve = false,
    required this.currentUsername,
    this.isFavorited = false,
    this.isLiked = false,
    this.onFavoriteToggle, // Callback for updating parent
    this.onLikeToggle,
    this.likeCount = 0,
    this.isImage = false,
  });

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isLiked = false; // State to track if the post is liked
  bool _isFavorited = false; // State to track if the post is favorited
  int _likeCount = 0; // State to track the like count
  late Animation<double> _animationForFavorite;
  late Animation<double> _animationForLike;
  late AnimationController _controllerForFavorite;
  late AnimationController _controllerForLike;

  @override
  void initState() {
    super.initState();
    // Initialize AnimationController and Animation
    _controllerForFavorite = getAnimationController();
    _animationForFavorite = getAnimation(_controllerForFavorite);
    _controllerForLike = getAnimationController();
    _animationForLike = getAnimation(_controllerForLike);
    setState(() {
      _isFavorited = widget.isFavorited;
      _isLiked = widget.isLiked;
      _likeCount = widget.likeCount;
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

  @override
  void dispose() {
    _controllerForFavorite.dispose();
    _controllerForLike.dispose();
    super.dispose();
  }

  void _toggleDescription() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      // Update like count based on the like state
      _likeCount += _isLiked ? 1 : -1;
      _controllerForLike.forward().then((_) => _controllerForLike.reverse());
    });
    if (_isLiked) {
      await ApiPostLikeService.createPostLike(widget.postId);
    } else {
      await ApiPostLikeService.removePostLike(widget.postId);
    }
    // Notify parent to refresh the data if a callback is provided
    widget.onLikeToggle!(_isLiked);
  }

  void _toggleFavorite() async {
    setState(() {
      _isFavorited = !_isFavorited;
      _controllerForFavorite
          .forward()
          .then((_) => _controllerForFavorite.reverse());
    });
    if (_isFavorited) {
      await ApiFavoriteService.createFavorite(widget.postId);
    } else {
      await ApiFavoriteService.removeFavorite(widget.postId);
    }
    // Notify parent to refresh the data if a callback is provided
    widget.onFavoriteToggle!(_isFavorited);
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog and do nothing
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor:
                    AppColors.primaryColor, // Change the text color to red
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor:
                    AppColors.primaryColor, // Change the text color to red
              ),
              onPressed: () {
                softDeletePost(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> softDeletePost(BuildContext context) async {
    // Check if the widget is still mounted before doing anything
    if (!mounted) return;

    try {
      // Call the API service to perform the soft delete
      Map<String, dynamic>? response =
          await ApiPostService.softDeletePost(widget.postId);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Show an error message if something went wrong
      CustomSnackbar.showSnackBar(
          context, 'An error occurred: ${e.toString()}', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Edit') {
                // Handle edit
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                      builder: (context) => CreatePostDialogMobile(
                          postId: widget.postId,
                          title: widget.title,
                          description: widget.description,
                          mediaUrl: widget.imageUrl,
                          isImage: widget.isImage)),
                );
              } else if (value == 'Delete') {
                // Handle delete
                _showDeleteConfirmationDialog(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem<String>(
                  value: 'Delete',
                  child: Text('Delete'),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 7, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.description.trim().isNotEmpty)
              Text(
                widget.description,
                maxLines: _isExpanded ? null : 2,
                overflow:
                    _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            if (widget.description.length > 10)
              GestureDetector(
                onTap: _toggleDescription,
                child: Text(
                  _isExpanded ? 'Show less' : 'Show more',
                  style: const TextStyle(color: AppColors.primaryColor),
                ),
              ),
            const SizedBox(height: 16.0),
            // Image view with Hero animation and zoom functionality
            Hero(
              tag: widget.imageUrl,
              child: widget.isImage
                  ? AspectRatio(
                      aspectRatio: 0.8,
                      child: FutureBuilder<Uint8List?>(
                        future: ApiImageService.fetchImage(widget.imageUrl),
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
                            return Image.asset(
                              'assets/images/image1.png',
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          } else if (snapshot.hasData) {
                            final imageBytes = snapshot.data!;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImageView(
                                      imageBytes: imageBytes,
                                      tag: widget.imageUrl,
                                    ),
                                  ),
                                );
                              },
                              child: Image.memory(
                                imageBytes,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: VideoPlayerWidget(mediaUrl: widget.imageUrl)),
            ),
            const SizedBox(height: 16.0),
            if (widget.approve)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('By: ${widget.username}'),
                      Text('Posted on: ${widget.createdDate}'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: AnimatedBuilder(
                          animation: _animationForLike,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isLiked ? _animationForLike.value : 1.0,
                              child: Icon(
                                _isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_alt_outlined,
                                color: widget.currentUsername == widget.username
                                    ? Colors.grey // Disabled color
                                    : _isLiked
                                        ? AppColors.primaryColor
                                        : Colors.black,
                              ),
                            );
                          },
                        ),
                        onPressed: widget.currentUsername == widget.username
                            ? null // Disable button if the current user is the author
                            : _toggleLike,
                      ),
                      // Display the like count
                      Text('$_likeCount'),
                      if (widget.currentUsername != widget.username)
                        IconButton(
                          icon: AnimatedBuilder(
                            animation: _animationForFavorite,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isFavorited
                                    ? _animationForLike.value
                                    : 1.0,
                                child: Icon(
                                  _isFavorited
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      widget.currentUsername == widget.username
                                          ? Colors.grey // Disabled color
                                          : _isFavorited
                                              ? Colors.red
                                              : Colors.black, // Enabled colors
                                ),
                              );
                            },
                          ),
                          onPressed: widget.currentUsername == widget.username
                              ? null // Disable button if the current user is the author
                              : _toggleFavorite,
                        ),
                    ],
                  ),
                ],
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
      ),
    );
  }
}

// Full screen image view with zoom
class FullScreenImageView extends StatelessWidget {
  final Uint8List imageBytes;
  final String tag;

  const FullScreenImageView(
      {super.key, required this.imageBytes, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Hero(
          tag: tag,
          child: InteractiveViewer(
            panEnabled: true, // Allow panning
            minScale: 1.0,
            maxScale: 4.0, // Allow zooming
            child: Image.memory(imageBytes),
          ),
        ),
      ),
    );
  }
}
