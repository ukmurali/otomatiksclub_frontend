import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:stem_club/constants.dart';
import 'package:stem_club/utils/user_auth_data.dart';
import 'package:stem_club/widgets/card_banner_swiper.dart';
import 'package:stem_club/widgets/custom_card.dart';
import 'package:stem_club/utils/dialog_utils.dart'; // Import the utility class
import 'dart:developer' as developer;

import 'package:stem_club/widgets/loading_indicator.dart';

class PostsListWidget extends StatefulWidget {
  final Future<Map<String, dynamic>?> Function()
      fetchPosts; // Function to fetch posts

  const PostsListWidget({super.key, required this.fetchPosts});

  @override
  _PostsListWidgetState createState() => _PostsListWidgetState();
}

class _PostsListWidgetState extends State<PostsListWidget> {
  List<dynamic> posts = [];
  bool isLoading = true;
  String currentUsername = '';

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

  Future<void> _fetchPosts() async {
    try {
      Map<String, dynamic>? result = await widget.fetchPosts();
      // Check if the result is null or status code is not 200
      if (result == null) {
        developer.log('No result received from API');
        _handleEmptyState(); // Handle empty case
        return;
      }

      // Check if body exists
      if (result['body'] is String) {
        final bodyDecoded = json.decode(result['body']);
        if (bodyDecoded is List) {
          final postData = List<Map<String, dynamic>>.from(bodyDecoded);
          setState(() {
            posts = postData;
            isLoading = false;
          });
        } else {
          _handleEmptyState();
        }
      } else if (result['body'] is List) {
        final postData = List<Map<String, dynamic>>.from(result['body']);
        setState(() {
          posts = postData;
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
      posts = []; // Ensure posts are empty if there's an error or no data
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;

    return SizedBox(
  width: isWeb ? 700 : double.infinity,
  child: Column(
    children: [
      // Static Card at the top
     const SwiperWidget(),
      // Expanded ListView for the posts, scrolling within available space
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: isLoading
              ? const Center(child: LoadingIndicator())
              : posts.isEmpty
                  ? const Center(child: Text("No posts available"))
                  : ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return CustomCard(
                          postId: post['postId'],
                          title: post['title'], // Post title
                          description: post['description'] ?? '', // Post description
                          username: post['username'],
                          isImage: post['postType'] == AppConstants.image ? true : false,
                          mediaUrl: post['postUrl'],
                          postedOn: post['updatedAt'],
                          currentUsername: currentUsername,
                        );
                      },
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
