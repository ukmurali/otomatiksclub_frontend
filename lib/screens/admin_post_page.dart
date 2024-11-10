import 'package:flutter/material.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/widgets/post_list_widget.dart';

class AdminPostPage extends StatelessWidget {
  const AdminPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post Tabs'),
          backgroundColor: Colors.grey[300],
          centerTitle: true, // Center the title
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              color: AppColors.textColor, // Set background color for the TabBar
              child: const TabBar(
                indicatorColor: AppColors.primaryColor, // Change the indicator (underline) color
                labelColor: AppColors.primaryColor, // Color of the selected tab label
                unselectedLabelColor: Colors.black, // Color for unselected tab labels
                tabs: [
                  Tab(text: 'Pending'),
                  Tab(text: 'Approved'),
                  Tab(text: 'Rejected'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              color: Colors.grey[300], // Set the background color
              child: const Center(
                child: PostsListWidget(isAllPost: true, postStatus: 'PENDING', role: 'ADMIN'),
              ),
            ),
            // Add background color for Approved tab
            Container(
              color: Colors.grey[300],  // Set the background color
              child: const Center(
                child: PostsListWidget(isAllPost: true, postStatus: 'APPROVED', role: 'ADMIN'),
              ),
            ),
            // Add background color for Rejected tab
            Container(
              color: Colors.grey[300],  // Set the background color
              child: const Center(
                child: PostsListWidget(isAllPost: true, postStatus: 'REJECTED', role: 'ADMIN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
