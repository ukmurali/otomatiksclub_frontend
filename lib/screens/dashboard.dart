import 'package:flutter/material.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:stem_club/constants.dart';
import 'package:stem_club/screens/home_page.dart';
import 'package:stem_club/screens/post_page.dart';
import 'package:stem_club/screens/profile_page.dart';
import 'package:stem_club/screens/video_page.dart';
import 'package:stem_club/screens/login_page.dart'; // Import your Login Page here
import 'package:stem_club/utils/dialog_utils.dart';
import 'package:stem_club/utils/utils.dart';
import 'club_activity_page.dart';
import 'notification_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String username = "";
  late String mobileNumber = "";
  late Map<String, dynamic>? user;

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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic>? userData = await getValue(AppConstants.userKey);
    Map<String, dynamic> userMap = userData?['user'];
    setState(() {
      username = userMap['username'];
      mobileNumber = userMap['mobileNumber'];
      user = userMap;
    });
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
          preferredSize: const Size.fromHeight(0.4),
          child: Container(
            color: Colors.grey,
            height: 1,
          ),
        ),
        actions: _isWeb(context)
            ? <Widget>[
                SizedBox(
                  width: 450.0,
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
                _buildProfileDropdown(),
              ]
            : null,
        automaticallyImplyLeading: !_isWeb(context),
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
    return MediaQuery.of(context).size.width > 600;
  }

  Widget _buildProfileDropdown() {
    String? profileImagePath = "";

    String initials = 'NA';
    if (username.isNotEmpty) {
      List<String> nameParts = username.split(' ');
      initials = nameParts.length > 1
          ? '${nameParts[0][0]}${nameParts[1][0]}'
          : username.substring(0, 2).toUpperCase();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: PopupMenuButton<String>(
        onSelected: (String value) {
          switch (value) {
            case 'Profile':
               _navigateProfilePage();
              break;
            case 'Settings':
              // Navigate to Settings page
              break;
            case 'Terms and Conditions':
              // Navigate to Terms and Conditions page
              break;
            case 'Logout':
              _handleLogout(); // Call logout method
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
              radius: 20.0,
              backgroundImage: profileImagePath.isNotEmpty
                  ? AssetImage(profileImagePath)
                  : null,
              backgroundColor: profileImagePath.isEmpty ? Colors.grey : null,
              child: profileImagePath.isEmpty
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
    DialogUtils.showCreatePostDialog(context);
  }

  Widget _buildDrawer(BuildContext context) {
     String? profileImagePath = "";

    String initials = 'NA';
    if (username.isNotEmpty) {
      List<String> nameParts = username.split(' ');
      initials = nameParts.length > 1
          ? '${nameParts[0][0]}${nameParts[1][0]}'
          : username.substring(0, 2).toUpperCase();
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: profileImagePath.isNotEmpty
                      ? AssetImage(profileImagePath)
                      : null,
                  backgroundColor:
                      profileImagePath.isEmpty ? Colors.grey : null,
                  child: profileImagePath.isEmpty
                      ? Text(
                          initials,
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(height: 16.0),
                Text(
                  username.isNotEmpty ? username : "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                Text(
                  mobileNumber.isNotEmpty ? mobileNumber : "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              _navigateProfilePage();
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
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              _handleLogout(); // Call logout method
            },
          ),
        ],
      ),
    );
  }

   void _navigateProfilePage() {
    // Navigate back to Login Page
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfilePage(phoneNumber: mobileNumber, user: user)),
    );
  }

  Future<void> _handleLogout() async {
    removeValue(AppConstants.userKey);
    navigateLoginPage();
  }

  void navigateLoginPage() {
    // Navigate back to Login Page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false, // Clear all previous routes
    );
  }
}
