import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:otomatiksclub/api/blog_service/api_blog_service.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/utils/user_auth_data.dart';
import 'package:otomatiksclub/widgets/custom_blog_card.dart';
import 'package:otomatiksclub/widgets/custom_snack_bar.dart';
import 'package:otomatiksclub/widgets/loading_indicator.dart';
import 'package:lottie/lottie.dart';

class BlogsListWidget extends StatefulWidget {
  const BlogsListWidget({super.key, this.role = 'STUDENT'});

  final String role;

  @override
  _BlogsListWidgetState createState() => _BlogsListWidgetState();
}

class _BlogsListWidgetState extends State<BlogsListWidget> {
  final ScrollController _scrollController = ScrollController();
  int currentPage = 0; // Current page for pagination
  String currentUsername = '';
  bool isLoading = true;
  final int pageSize = 10; // Number of Blogs per page
  List<dynamic> blogs = [];
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    setUsername();
    _fetchBlogs(); // Fetch blogs when the widget is initialized
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoadingMore) {
      currentPage++;
      _fetchBlogs(isLoadMore: true); // Load more blogs when reaching the end
    }
  }

  Future<void> setUsername() async {
    UserAuthData userAuthData = await getUserIdAndAuthToken();
    String? username = userAuthData.username;
    setState(() {
      currentUsername = username ?? '';
    });
  }

  Future<void> _fetchBlogs({bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() => isLoadingMore = true);
    } else {
      setState(() => isLoading = true);
    }
    try {
      Map<String, dynamic>? result;
      result = await ApiBlogService.getBlogs(
        currentPage,
        pageSize,
      );
      if (result != null && result['statusCode'] == 200) {
        final List<dynamic> newBlogs =
            List<Map<String, dynamic>>.from(json.decode(result['body']));
        setState(() {
          if (isLoadMore) {
            blogs.addAll(newBlogs);
            isLoadingMore = false;
          } else {
            blogs = newBlogs;
            isLoading = false;
          }
        });
        if (newBlogs.length < pageSize) {
          _scrollController.removeListener(_onScroll); // No more blogs to load
        }
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
      // No need to clear blogs, keep existing blogs unless needed
    });
  }

  Future<void> _refreshBlogs() async {
    setState(() {
      currentPage = 0; // Reset to the first page
      blogs.clear(); // Clear current blogs
    });
    await _fetchBlogs();
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
          // Expanded ListView for the blogs, scrolling within available space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: isLoading
                  ? const Center(child: LoadingIndicator())
                  : RefreshIndicator(
                      onRefresh: _refreshBlogs,
                      color: AppColors.primaryColor,
                      child: blogs.isEmpty
                          ? Center(
                              // Ensures content is centered in the available space
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Image above the "No blogs available" text
                                  Lottie.asset(
                                    'assets/no_post.json', // Path to your Lottie file
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                      height:
                                          10), // Space between image and text
                                  const Text("No blogs available"),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: blogs.length + (isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == blogs.length) {
                                  return const Center(
                                      child: LoadingIndicator());
                                }
                                final blog = blogs[index];
                                return CustomBlogCard(
                                  blogId: blog['blogId'],
                                  title: blog['title'],
                                  description: blog['description'] ?? '',
                                  username: blog['username'],
                                  isImage:
                                      blog['blogType'] == AppConstants.image,
                                  mediaUrl: blog['blogUrl'],
                                  postedOn: blog['updatedAt'],
                                  currentUsername: currentUsername,
                                  role: widget.role,
                                );
                              },
                            ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
