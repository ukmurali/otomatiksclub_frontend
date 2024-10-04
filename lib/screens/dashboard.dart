// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:stem_club/constants.dart';
import 'package:stem_club/screens/home_page.dart';
import 'package:stem_club/screens/post_page.dart';
import 'package:stem_club/screens/video_page.dart';
import 'package:stem_club/utils/dialog_utils.dart';
import 'club_activity_page.dart';
import 'notification_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ClubActivityPage(),
    PostPage(),
    VideoPage(),
    NotificationPage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _widgetOptions.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: AppColors.textColor,
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(0.4), // Height of the border line
          child: Container(
            color: Colors.grey, // Color of the border line
            height: 1, // Thickness of the border line
          ),
        ),
        actions: _isWeb(context)
            ? <Widget>[
                SizedBox(
                  width: 450.0, // Adjust width as needed
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primaryColor,
                    labelColor: AppColors.primaryColor,
                    unselectedLabelColor: AppColors.tabIconColor,
                    tabs: const [
                      Tab(icon: Icon(Icons.home), text: 'Home'),
                      Tab(icon: Icon(Icons.group), text: 'My Club'),
                      Tab(icon: Icon(Icons.video_library), text: 'Video'),
                      Tab(
                          icon: Icon(Icons.notifications),
                          text: 'Notifications'),
                    ],
                  ),
                ),
                _buildProfileDropdown(), // Profile dropdown at the right end
              ]
            : null,
        automaticallyImplyLeading:
            !_isWeb(context), // Hide back button in web view
      ),
      drawer: _isWeb(context) ? null : _buildDrawer(context),
      body: _isWeb(context)
          ? TabBarView(
              controller: _tabController,
              children: _widgetOptions,
            )
          : _widgetOptions.elementAt(_tabController.index),
      bottomNavigationBar: _isWeb(context) ? null : _buildBottomNavigationBar(),
      floatingActionButton: !_isWeb(context)
          ? FloatingActionButton(
              onPressed: _onFabPressed,
              elevation: 10.0,
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Icon(Icons.add, size: 30.0),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  bool _isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width >
        600; // Adjust this breakpoint as needed
  }

  Widget _buildProfileDropdown() {
    String? profileImagePath; // Path to the profile image, if available
    String? username; // The username, if available

    // Extract the initials from the username, or default to "NA"
    String initials = 'NA';
    if (username != null && username.isNotEmpty) {
      List<String> nameParts = username.split(' ');
      initials = nameParts.length > 1
          ? '${nameParts[0][0]}${nameParts[1][0]}'
          : username.substring(0, 1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Adjust padding as needed
      child: PopupMenuButton<String>(
        onSelected: (String value) {
          // Handle menu selection
          switch (value) {
            case 'Profile':
              // Navigate to Profile page
              break;
            case 'Settings':
              // Navigate to Settings page
              break;
            case 'Terms and Conditions':
              // Navigate to Terms and Conditions page
              break;
            case 'Logout':
              // Handle logout
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          return [
            const PopupMenuItem<String>(
              value: 'Profile',
              child: Row(
                children: <Widget>[
                  Icon(Icons.person),
                  SizedBox(width: 8.0),
                  Text('Profile'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'Settings',
              child: Row(
                children: <Widget>[
                  Icon(Icons.settings),
                  SizedBox(width: 8.0),
                  Text('Settings'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'Terms and Conditions',
              child: Row(
                children: <Widget>[
                  Icon(Icons.description),
                  SizedBox(width: 8.0),
                  Text('Terms and Conditions'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'Logout',
              child: Row(
                children: <Widget>[
                  Icon(Icons.exit_to_app),
                  SizedBox(width: 8.0),
                  Text('Logout'),
                ],
              ),
            ),
          ];
        },
        icon: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 20.0, // Adjust radius as needed
              backgroundImage: profileImagePath != null
                  ? AssetImage(profileImagePath)
                  : null,
              backgroundColor: profileImagePath == null ? Colors.grey : null,
              child: profileImagePath == null
                  ? Text(
                      initials,
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 8.0),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'My Club',
        ),
        BottomNavigationBarItem(
          icon: SizedBox.shrink(),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_library),
          label: 'Video',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
      ],
      currentIndex: _tabController.index,
      selectedItemColor: AppColors.primaryColor,
      onTap: (index) {
        setState(() {
          _tabController.index = index;
        });
      },
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }

  void _onFabPressed() {
    // Handle FAB press
    DialogUtils.showCreatePostDialog(context); // Use the utility method
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30.0,
                  backgroundImage:
                      AssetImage('assets/images/profile_image.png'),
                ),
                SizedBox(height: 16.0),
                Text(
                  'User Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                Text(
                  'user@example.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              // Handle profile tap
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Handle settings tap
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms and Conditions'),
            onTap: () {
              // Handle terms and conditions tap
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              // Handle logout tap
            },
          ),
        ],
      ),
    );
  }
}
