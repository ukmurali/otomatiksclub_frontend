import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:otomatiksclub/api/post_service/api_post_service.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/utils/utils.dart';
import 'package:otomatiksclub/widgets/post_list_widget.dart';

class AdminPostPage extends StatefulWidget {
  const AdminPostPage({super.key});

  @override
  _AdminPostPageState createState() => _AdminPostPageState();
}

class _AdminPostPageState extends State<AdminPostPage> {
  int postPending = 0;
  int postApproved = 0;
  int postRejected = 0;

    @override
  void initState() {
    super.initState();
    _fetchPostStatusCount();
  }

  Future<void> _fetchPostStatusCount() async {
    Map<String, dynamic>? result = await ApiPostService.fetchPostStatusCount();
    if (result != null && result['statusCode'] == 200) {
      Map<String, dynamic>? postStatusCount =
          Map<String, dynamic>.from(json.decode(result['body']));
      setState(() {
        postPending = postStatusCount['totalPostsPending'];
        postApproved = postStatusCount['totalPostsApproved'];
        postRejected = postStatusCount['totalPostsRejected'];
      });
    }
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
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[300],
          centerTitle: true, // Center the title
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Column(
              children: [
                Container(
                  color: Colors.grey[300],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCountTab('Pending', postPending),
                      _buildCountTab('Approved', postApproved),
                      _buildCountTab('Rejected', postRejected),
                    ],
                  ),
                ),
                Container(
                  color: AppColors
                      .textColor, // Set background color for the TabBar
                  child: const TabBar(
                    indicatorColor: AppColors
                        .primaryColor, // Change the indicator (underline) color
                    labelColor: AppColors
                        .primaryColor, // Color of the selected tab label
                    unselectedLabelColor:
                        Colors.black, // Color for unselected tab labels
                    tabs: [
                      Tab(text: 'Pending'),
                      Tab(text: 'Approved'),
                      Tab(text: 'Rejected'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              color: Colors.grey[300], // Set the background color
              child: const Center(
                child: PostsListWidget(
                    isAllPost: true, postStatus: 'PENDING', role: 'ADMIN'),
              ),
            ),
            // Add background color for Approved tab
            Container(
              color: Colors.grey[300], // Set the background color
              child: const Center(
                child: PostsListWidget(
                    isAllPost: true, postStatus: 'APPROVED', role: 'ADMIN'),
              ),
            ),
            // Add background color for Rejected tab
            Container(
              color: Colors.grey[300], // Set the background color
              child: const Center(
                child: PostsListWidget(
                    isAllPost: true, postStatus: 'REJECTED', role: 'ADMIN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
