import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:otomatiksclub/api/favorite_service/api_favorite_service.dart';
import 'package:otomatiksclub/api/post_service/api_post_service.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/utils/user_auth_data.dart';
import 'package:otomatiksclub/widgets/custom_card.dart';
import 'package:otomatiksclub/utils/dialog_utils.dart';
import 'package:otomatiksclub/widgets/custom_snack_bar.dart';
import 'package:otomatiksclub/widgets/loading_indicator.dart';
import 'package:lottie/lottie.dart';

class PostsListWidget extends StatefulWidget {
  const PostsListWidget(
      {super.key,
      this.isAllPost = false,
      this.isMyFavorite = false,
      required this.postStatus,
      this.role = 'STUDENT'});

  final bool isAllPost;
  final bool isMyFavorite;
  final String postStatus;
  final String role;

  @override
  _PostsListWidgetState createState() => _PostsListWidgetState();
}

class _PostsListWidgetState extends State<PostsListWidget> {
  final ScrollController _scrollController = ScrollController();
  int currentPage = 0; // Current page for pagination
  String currentUsername = '';
  bool isLoading = true;
  final int pageSize = 10; // Number of posts per page
  List<dynamic> posts = [];
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    setUsername();
    _fetchPosts(); // Fetch posts when the widget is initialized
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoadingMore) {
      currentPage++;
      _fetchPosts(isLoadMore: true); // Load more posts when reaching the end
    }
  }

  Future<void> setUsername() async {
    UserAuthData userAuthData = await getUserIdAndAuthToken();
    String? username = userAuthData.username;
    setState(() {
      currentUsername = username ?? '';
    });
  }

  void refreshPost(String postId, String action) async {
    // Fetch the updated post data from the API
    final updatedPost = await ApiPostService.getPost(postId);
    // Find the index of the updated post
    final index = posts.indexWhere((post) => post['postId'] == postId);
    if (index != -1) {
      setState(() {
        if (updatedPost != null) {
          final updatedPostRes = updatedPost['body'];
          final parsedPost = jsonDecode(updatedPostRes);
          if (parsedPost is Map<String, dynamic>) {
            if (action == 'favorite') {
              posts.removeAt(index);
            } else {
              // Update posts list
              posts[index] = parsedPost;
            }
          }
        }
      });
    }
  }

  Future<void> _fetchPosts({bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() {
        isLoadingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
      });
    }
    try {
      Map<String, dynamic>? result;
      if (widget.isMyFavorite) {
        result =
            await ApiFavoriteService.getMyFavoritePost(currentPage, pageSize);
      } else {
        result = await ApiPostService.getAllPost(
          widget.isAllPost,
          currentPage,
          pageSize,
          postStatus: widget.postStatus,
        );
      }
      if (result != null && result['statusCode'] == 200) {
        final List<dynamic> newPosts =
            List<Map<String, dynamic>>.from(json.decode(result['body']));
        setState(() {
          if (isLoadMore) {
            posts.addAll(newPosts);
            isLoadingMore = false;
          } else {
            posts = newPosts;
            isLoading = false;
          }
        });
      } else {
        CustomSnackbar.showSnackBar(context, result?['body'], false);
        _handleEmptyState();
        return;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void _handleEmptyState() {
    if (!mounted) return; // Prevent setState if the widget is not mounted
    setState(() {
      isLoading = false; // Stop loading
      // No need to clear posts, keep existing posts unless needed
    });
  }

  Future<void> _refreshPosts() async {
    setState(() {
      currentPage = 0; // Reset to the first page
      posts.clear(); // Clear current posts
    });
    await _fetchPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;

    return SizedBox(
      width: isWeb ? 700 : double.infinity,
      child: Column(
        children: [
          // Expanded ListView for the posts, scrolling within available space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: isLoading
                  ? const Center(child: LoadingIndicator())
                  : RefreshIndicator(
                      onRefresh: _refreshPosts,
                      color: AppColors.primaryColor,
                      child: posts.isEmpty
                          ? Center(
                              // Ensures content is centered in the available space
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Image above the "No posts available" text
                                  Lottie.asset(
                                    'assets/no_post.json', // Path to your Lottie file
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                      height:
                                          10), // Space between image and text
                                  const Text("No posts available"),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: posts.length + (isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == posts.length) {
                                  return const Center(
                                      child: LoadingIndicator());
                                }
                                final post = posts[index];
                                return CustomCard(
                                    postId: post['postId'],
                                    title: post['title'],
                                    description: post['description'] ?? '',
                                    username: post['username'],
                                    isImage:
                                        post['postType'] == AppConstants.image,
                                    mediaUrl: post['postUrl'],
                                    postedOn: post['updatedAt'],
                                    postStatus: post['postStatus'],
                                    currentUsername: currentUsername,
                                    isFavorited: post['favorited'],
                                    isMyFavorite: widget.isMyFavorite,
                                    onFavoriteToggle: () =>
                                        refreshPost(post['postId'], 'favorite'),
                                    onLikeToggle: () =>
                                        refreshPost(post['postId'], 'like'),
                                    isLiked: post['liked'],
                                    totalLikes: post['totalLikes'],
                                    role: widget.role,
                                    onApprovePost: () {
                                      setState(() {
                                        currentPage = 0;
                                      });
                                      _fetchPosts();
                                    });
                              },
                            ),
                    ),
            ),
          ),
          // Create Post button for web, stays at the bottom
          if (isWeb)
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    DialogUtils.showCreatePostDialog(context);
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Create Post',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    elevation: 5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
