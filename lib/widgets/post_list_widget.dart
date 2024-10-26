import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stem_club/api/favorite_service/api_favorite_service.dart';
import 'package:stem_club/api/post_service/api_post_service.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:stem_club/constants.dart';
import 'package:stem_club/utils/user_auth_data.dart';
import 'package:stem_club/widgets/custom_card.dart';
import 'package:stem_club/utils/dialog_utils.dart';
import 'package:stem_club/widgets/loading_indicator.dart';
import 'dart:developer' as developer;

class PostsListWidget extends StatefulWidget {
  const PostsListWidget(
      {super.key, this.isAllPost = false, this.isMyFavorite = false});

  final bool isAllPost;
  final bool isMyFavorite;

  @override
  _PostsListWidgetState createState() => _PostsListWidgetState();
}

class _PostsListWidgetState extends State<PostsListWidget> {
  int currentPage = 0; // Current page for pagination
  String currentUsername = '';
  bool isLoading = true;
  final int pageSize = 10; // Number of posts per page
  List<dynamic> posts = [];

  @override
  void initState() {
    super.initState();
    setUsername();
    _fetchPosts(); // Fetch posts when the widget is initialized
  }

  Future<void> setUsername() async {
    UserAuthData userAuthData = await getUserIdAndAuthToken();
    String? username = userAuthData.username;
    setState(() {
      currentUsername = username ?? '';
    });
  }

  void refreshPost(String postId) async {
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
            if(widget.isMyFavorite){
              posts.removeAt(index);
            }
            else{
              // Update posts list
              posts[index] = parsedPost;
            }
          }
        }
      });
    }
  }

  Future<void> _fetchPosts() async {
    try {
      Map<String, dynamic>? result;
      if (widget.isMyFavorite) {
        result =
            await ApiFavoriteService.getMyFavoritePost(currentPage, pageSize);
      } else {
        result = await ApiPostService.getAllPost(
            widget.isAllPost, currentPage, pageSize);
      }
      if (result == null) {
        developer.log('No result received from API');
        _handleEmptyState(); // Handle empty case
        return;
      }

      if (result['body'] is String) {
        final bodyDecoded = json.decode(result['body']);
        if (bodyDecoded is List) {
          final postData = List<Map<String, dynamic>>.from(bodyDecoded);
          setState(() {
            posts.addAll(postData); // Add new posts to the existing list
            isLoading = false;
          });
        } else {
          _handleEmptyState();
        }
      } else if (result['body'] is List) {
        final postData = List<Map<String, dynamic>>.from(result['body']);
        setState(() {
          posts.addAll(postData); // Add new posts to the existing list
          isLoading = false;
        });
      } else {
        _handleEmptyState();
      }
    } catch (e) {
      _handleEmptyState();
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
      isLoading = true; // Show loading when refreshing
      currentPage = 0; // Reset to the first page
      posts.clear(); // Clear current posts
    });
    await _fetchPosts();
  }

  Future<void> _loadMorePosts() async {
    setState(() {
      currentPage++; // Increment the current page
      isLoading = true; // Show loading indicator while fetching more posts
    });
    await _fetchPosts();
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
              child: isLoading && posts.isEmpty
                  ? const Center(child: LoadingIndicator())
                  : RefreshIndicator(
                      onRefresh: _refreshPosts,
                      color: AppColors.primaryColor,
                      child: posts.isEmpty
                          ? const Center(child: Text("No posts available"))
                          : ListView.builder(
                              itemCount: posts.length +
                                  1, // +1 for the load more button
                              itemBuilder: (context, index) {
                                if (index < posts.length) {
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
                                    approve: post['approve'],
                                    currentUsername: currentUsername,
                                    isFavorited: post['favorited'],
                                    isMyFavorite: widget.isMyFavorite,
                                    onFavoriteToggle: () =>
                                        refreshPost(post['postId']),
                                  );
                                } else {
                                  // Load more button
                                  return Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: SizedBox(
                                      width: 200,
                                      child: ElevatedButton(
                                        onPressed: _loadMorePosts,
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: AppColors
                                              .primaryColor, // Text color
                                        ),
                                        child: isLoading
                                            ? const CircularProgressIndicator(
                                                color: AppColors.primaryColor,
                                              )
                                            : const Text('Load More'),
                                      ),
                                    ),
                                  );
                                }
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
