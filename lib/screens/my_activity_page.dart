import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:otomatiksclub/api/club_service/api_club_service.dart';
import 'package:otomatiksclub/api/post_service/api_post_service.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/screens/post_details_page.dart';
import 'package:otomatiksclub/utils/user_auth_data.dart';
import 'package:otomatiksclub/utils/utils.dart';
import 'package:otomatiksclub/widgets/custom_grid_card.dart';
import 'package:otomatiksclub/widgets/custom_snack_bar.dart';
import 'package:otomatiksclub/widgets/loading_indicator.dart';

class MyActivityWidget extends StatefulWidget {
  const MyActivityWidget({super.key});

  @override
  _MyActivityWidgetState createState() => _MyActivityWidgetState();
}

class _MyActivityWidgetState extends State<MyActivityWidget>
    with SingleTickerProviderStateMixin {
  int currentPage = 0;
  bool isLoading = true;
  bool isLoadingMore = false;
  List<dynamic> posts = [];
  late TabController _tabController;
  String currentUsername = '';
  final ScrollController _scrollController = ScrollController();

  int postCount = 0;
  int postApproved = 0;
  int likesCount = 0;
  int clubPoints = 100;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchPosts(); // Initial post load
    _scrollController.addListener(_onScroll);
    _fetchClubStatistics();
  }

  Future<void> setUsername() async {
    UserAuthData userAuthData = await getUserIdAndAuthToken();
    String? username = userAuthData.username;
    setState(() {
      currentUsername = username ?? '';
    });
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
      switch (_tabController.index) {
        case 0:
          result = await ApiPostService.getAllPost(false, currentPage, 10, postStatus: 'PENDING');
          break;
        case 1:
          result = await ApiPostService.getAllPost(false, currentPage, 10,
              postType: AppConstants.video, allPostMediaType: false, postStatus: 'PENDING');
          break;
        case 2:
          result = await ApiPostService.getAllPost(false, currentPage, 10, postStatus: 'PENDING');
          break;
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

  Future<void> _fetchClubStatistics() async {
    Map<String, dynamic>? result = await ApiClubService.fetchClubStatistics();
    if (result != null && result['statusCode'] == 200) {
      Map<String, dynamic>? clubStatistic = result['body'];
      if (clubStatistic != null) {
        setState(() {
          clubPoints = clubStatistic['totalClubPoints'];
          postCount = clubStatistic['totalPostsCount'];
          postApproved = clubStatistic['totalPostsApproved'];
          likesCount = clubStatistic['totalLikes'];
        });
      }
    }
  }

  void _handleEmptyState() {
    if (!mounted) return; // Prevent setState if the widget is not mounted
    setState(() {
      isLoading = false; // Stop loading
      // No need to clear posts, keep existing posts unless needed
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoadingMore) {
      currentPage++;
      _fetchPosts(isLoadMore: true); // Load more posts when reaching the end
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildCountTab(String label, int count) {
    String textCount = formatCount(count);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(
          textCount,
          style: const TextStyle(
              fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Counts tab row above TabBar
        Container(
          color: Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCountTab('Club Points', clubPoints),
              _buildCountTab('Posts', postCount),
              _buildCountTab('Approved', postApproved),
              _buildCountTab('Likes', likesCount),
            ],
          ),
        ),
        // Main TabBar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryColor,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.apps)),
              Tab(icon: Icon(Icons.video_library)),
              Tab(icon: Icon(Icons.image)),
            ],
            onTap: (_) {
              setState(() {
                currentPage = 0;
                posts.clear();
                _fetchPosts(); // Refresh posts based on selected tab
              });
            },
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: LoadingIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      currentPage = 0;
                      posts.clear();
                    });
                    await _fetchPosts();
                  },
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
                                  height: 10), // Space between image and text
                              const Text("No activity available"),
                            ],
                          ),
                        )
                      : GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(1.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: posts.length + (isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == posts.length) {
                              return const Center(child: LoadingIndicator());
                            }
                            final post = posts[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PostDetailPage(
                                            postId: post['postId'],
                                            title: post['postId'],
                                            description: post['postId'] ?? '',
                                            imageUrl: post['postUrl'],
                                            username:
                                                post['username'] ?? 'Unknown',
                                            createdDate:
                                                post['createdAt'] ?? '',
                                            postStatus: post['postStatus'],
                                            currentUsername: currentUsername,
                                            likeCount: post['totalLikes'],
                                            isLiked: post['isLiked'],
                                            isFavorited: post['isFavorited'],
                                            isImage: post['postType'] ==
                                                AppConstants.image,
                                          )),
                                );
                              },
                              child: CustomGridCard(
                                postId: post['postId'],
                                title: post['title'],
                                description: post['description'] ?? '',
                                username: post['username'],
                                isImage: post['postType'] == AppConstants.image,
                                mediaUrl: post['postUrl'],
                                postedOn: post['updatedAt'],
                                currentUsername: currentUsername,
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}
