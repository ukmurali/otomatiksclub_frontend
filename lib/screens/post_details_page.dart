import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:otomatiksclub/api/blog_service/api_blog_service.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/screens/comment_page.dart';
import 'package:otomatiksclub/widgets/custom_alert_dialog.dart';
import 'package:otomatiksclub/widgets/no_internet_view.dart';
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
  final String postStatus;
  final String currentUsername;
  final bool isFavorited;
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final Function(bool)? onFavoriteToggle;
  final Function(bool)? onLikeToggle;
  final bool isImage;
  final String role;
  final Function(String)? onApprovePost;
  final String postAction;

  const PostDetailPage({
    super.key,
    required this.postId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.username,
    required this.createdDate,
    required this.postStatus,
    required this.currentUsername,
    this.isFavorited = false,
    this.isLiked = false,
    this.onFavoriteToggle, // Callback for updating parent
    this.onLikeToggle,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isImage = false,
    required this.role,
    this.onApprovePost,
    this.postAction = 'Post',
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
  int _commentCount = 0;
  late String postStatus;
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
      _commentCount = widget.commentCount;
      postStatus = widget.postStatus;
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
    Map<String, dynamic>? response;
    if (_isLiked) {
      response = await ApiPostLikeService.createPostLike(widget.postId);
    } else {
      response = await ApiPostLikeService.removePostLike(widget.postId);
    }
    if (response['statusCode'] != 201 || response['statusCode'] != 200) {
      if (response['body'] == 'Exception: No internet connection available') {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoInternetPage(),
            ),
          );
        }
      } else {
        CustomSnackbar.showSnackBar(
            context, 'Please try again after sometime', false);
      }
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
    Map<String, dynamic>? response;
    if (_isFavorited) {
      response = await ApiFavoriteService.createFavorite(widget.postId);
    } else {
      response = await ApiFavoriteService.removeFavorite(widget.postId);
    }
    if (response['statusCode'] != 201 || response['statusCode'] != 200) {
      if (response['body'] == 'Exception: No internet connection available') {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoInternetPage(),
            ),
          );
        }
      } else {
        CustomSnackbar.showSnackBar(
            context, 'Please try again after sometime', false);
      }
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
                deletePost(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deletePost(BuildContext context) async {
    // Check if the widget is still mounted before doing anything
    if (!mounted) return;

    try {
      // Call the API service to perform the soft delete
      Map<String, dynamic>? response = widget.postAction == 'Post'
          ? await ApiPostService.deletePost(widget.postId, widget.imageUrl)
          : await ApiBlogService.deleteBlog(widget.postId);
      if (response != null && response['statusCode'] != 200) {
        if (response['body'] == 'Exception: No internet connection available') {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NoInternetPage(),
              ),
            );
          }
        } else {
          CustomSnackbar.showSnackBar(
              context, 'Please try again after sometime', false);
        }
      }
      int index = widget.postAction == 'Post' ? 1 : 3;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => DashboardPage(initialTabIndex: index)),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Show an error message if something went wrong
      CustomSnackbar.showSnackBar(
          context, 'An error occurred: ${e.toString()}', false);
    }
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, String action, String postId) async {
    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ActionDialog(
          action: action,
          postId: postId,
          onApprove: () => _approveOrRejectPost(context, 'approve', postId, ''),
          onReject: (reason) {
            _approveOrRejectPost(context, 'reject', postId, reason);
          },
        );
      },
    );
  }

  Future<void> _approveOrRejectPost(
      BuildContext context, String action, String postId, String reason) async {
    // Check if the widget is still mounted before doing anything
    if (!mounted) return;

    try {
      // Call the API service to perform the soft delete
      Map<String, dynamic>? response =
          await ApiPostService.approveOrRejectPost(action, postId, reason);
      if (response['statusCode'] != 200) {
        if (response['body'] == 'Exception: No internet connection available') {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NoInternetPage(),
              ),
            );
          }
        } else {
          CustomSnackbar.showSnackBar(
              context, 'Please try again after sometime', false);
        }
        return;
      }
      //CustomSnackbar.showSnackBar(context, response['body'], true);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const DashboardPage(initialTabIndex: 1)),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomSnackbar.showSnackBar(
            context, 'Please try again after sometime', false);
      });
    }
  }

  void _navigateCommentPage() {
    Navigator.of(context, rootNavigator: true)
        .push(
      MaterialPageRoute(
        builder: (context) => CommentPage(
          postId: widget.postId,
          currentUsername: widget.currentUsername,
        ),
      ),
    )
        .then((result) {
      // Callback logic here
      if (result != null) {
        // Perform any actions with the result
        //print('result: $result');
        setState(() {
          _commentCount = result;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions:
            widget.username == widget.currentUsername || widget.role == AppConstants.BA
                ? <Widget>[
                    PopupMenuButton<String>(
                      onSelected: (String value) {
                        if (value == 'Edit') {
                          // Handle edit
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                                builder: (context) => CreatePostDialogMobile(
                                    postId: widget.postId,
                                    title: widget.title,
                                    username: widget.username,
                                    description: widget.description,
                                    postAction: widget.postAction,
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
                  ]
                : null,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('By: ${widget.username}'),
                    Text('Posted on: ${widget.createdDate}'),
                    if (widget.currentUsername == widget.username ||
                        widget.role != AppConstants.STD)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.comment,
                              color: Colors.black, // Enabled colors
                            ),
                            onPressed: _navigateCommentPage,
                          ),
                          Text(
                            '$_commentCount Comment(s)',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                  ],
                ),
                if (postStatus == 'APPROVED' && widget.role == AppConstants.STD)
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
            ),
            if (postStatus == 'PENDING' && widget.role == AppConstants.BA)
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Approve Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green, // Green color for approve
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {
                        _showConfirmationDialog(
                            context, 'Approve', widget.postId);
                      },
                      child: const Text(
                        "Approve",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Reject Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Red color for reject
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {
                        _showConfirmationDialog(
                            context, 'Reject', widget.postId);
                      },
                      child: const Text(
                        "Reject",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.postAction == 'Post' &&
                widget.role == AppConstants.STD &&
                widget.postStatus != 'APPROVED')
              Container(
                color: widget.postStatus == 'PENDING'
                    ? Colors.orange
                    : Colors.red, // Background color for the SizedBox
                child: SizedBox(
                  height: 25, // Height of the SizedBox
                  child: Center(
                    child: Text(
                      widget.postStatus,
                      style: const TextStyle(
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
