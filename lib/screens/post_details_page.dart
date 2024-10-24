import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stem_club/api/image_service/api_image_service.dart';
import 'package:stem_club/api/post_Service/api_post_service.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:stem_club/screens/create_post_dialog_mobile.dart';
import 'package:stem_club/screens/dashboard.dart';
import 'package:stem_club/widgets/custom_snack_bar.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  final String title;
  final String description;
  final String imageUrl;
  final String username;
  final String createdDate;

  const PostDetailPage({
    super.key,
    required this.postId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.username,
    required this.createdDate,
  });

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool _isExpanded = false;
  bool _isLiked = false; // State to track if the post is liked
  bool _isFavorited = false; // State to track if the post is favorited
  int _likeCount = 0; // State to track the like count

  void _toggleDescription() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      // Update like count based on the like state
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
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
          await ApiPostService.softDeletePost(widget.postId!);

      // Check if the response is null
      if (response == null) {
        CustomSnackbar.showSnackBar(
            context, 'Please try again after sometime', false);
        return;
      }
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
                          mediaUrl: widget.imageUrl)),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
              child: AspectRatio(
                aspectRatio: 1,
                child: FutureBuilder<Uint8List?>(
                  future: ApiImageService.fetchImage(widget.imageUrl),
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
              ),
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
                  ],
                ),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        color: _isLiked ? Colors.blue : null,
                      ),
                      onPressed: _toggleLike,
                    ),
                    // Display the like count
                    Text('$_likeCount'),
                    IconButton(
                      icon: Icon(
                        _isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorited ? Colors.red : null,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ],
                ),
              ],
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
