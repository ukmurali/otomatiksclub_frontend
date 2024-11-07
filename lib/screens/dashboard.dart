import 'package:flutter/material.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/screens/ClubSelectionPage.dart';
import 'package:otomatiksclub/screens/blog_page.dart';
import 'package:otomatiksclub/screens/home_page.dart';
import 'package:otomatiksclub/screens/my_favorite_page.dart';
import 'package:otomatiksclub/screens/notification_page.dart';
import 'package:otomatiksclub/screens/post_page.dart';
import 'package:otomatiksclub/screens/profile_page.dart';
import 'package:otomatiksclub/screens/login_page.dart';
import 'package:otomatiksclub/utils/utils.dart';
import 'package:otomatiksclub/screens/create_post_dialog_mobile.dart';

class DashboardPage extends StatefulWidget {
  final int initialTabIndex;
  const DashboardPage({super.key, this.initialTabIndex = 0});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late String mobileNumber = "";
  late Map<String, dynamic>? user;
  late String username = "";
  late String dateOfdobBirth;
  late String clubLevel = "";
  late String clubName = "Club";
  late String clubId = "";

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MyPostsPage(),
    CreatePostDialogMobile(),
    InstagramMediaPage(),
    ClubSelectionPage(),
  ];

  late TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _widgetOptions.length,
      vsync: this,
      initialIndex: widget.initialTabIndex, // Initialize with the passed index
    );
    _loadUserData();
  }

  void navigateLoginPage() {
    // Navigate back to Login Page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false, // Clear all previous routes
    );
  }

  void navigateNotificationPage() {
    // Navigate back to Login Page
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const NotificationPage()));
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic>? userData = await getValue(AppConstants.userKey);
    Map<String, dynamic> userMap = userData?['user'];
    Map<String, dynamic>? clubData = await getValue(AppConstants.clubKey);
    setState(() {
      username = userMap['username'];
      mobileNumber = userMap['mobileNumber'];
      dateOfdobBirth = userMap['dateOfBirthString'];
      clubLevel = getAgeGroup(dateOfdobBirth);
      user = userMap;
      clubName = clubData?['name'];
      clubId = clubData?['id'];
    });
  }

  bool _isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  Widget _buildProfileDropdown() {
    String? profileImagePath = "";

    String initials = getInitials(username);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: PopupMenuButton<String>(
        onSelected: (String value) {
          switch (value) {
            case 'Profile':
              _navigateProfilePage();
              break;
            case 'My Favorites':
              // Navigate to My Favorites page
              _navigateMyFavoritePage();
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
              value: 'My Favorites',
              child: Row(
                children: <Widget>[
                  Icon(Icons.favorite),
                  SizedBox(width: 8.0),
                  Text('My Favorites'),
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

   void _onBottomNavTapped(int index) {
    if (index == 4) {  // "Club Space" is the last item in the BottomNavigationBar
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ClubSelectionPage()),  // Navigate to Club Space page
      );
    } else {
      setState(() {
        _tabController.index = index;
      });
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_activity),
          label: 'My Activity',
        ),
        BottomNavigationBarItem(
          icon: SizedBox.shrink(),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.feed),
          label: 'Blog',
        ),
        BottomNavigationBarItem(
          // Add new navigation item
          icon: Icon(Icons.group),
          label: 'Club Space',
        ),
      ],
      currentIndex: _tabController.index,
      selectedItemColor: AppColors.primaryColor,
      onTap: _onBottomNavTapped,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle:
          const TextStyle(fontSize: 10), // Adjust selected text size
      unselectedLabelStyle:
          const TextStyle(fontSize: 10), // Adjust unselected text size
    );
  }

  void _onFabPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostDialogMobile()),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    String? profileImagePath = "";

    String initials = getInitials(username);
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
                Row(
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
                    const SizedBox(width: 16.0),
                    Text(
                      username.isNotEmpty ? username : "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Text(
                  clubLevel.isNotEmpty ? clubLevel : "",
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
            leading: const Icon(Icons.favorite),
            title: const Text('My Favorites'),
            onTap: () {
              // Handle My Favorites tap
              _navigateMyFavoritePage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms and Conditions'),
            onTap: () {},
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
          builder: (context) =>
              ProfilePage(phoneNumber: mobileNumber, user: user)),
    );
  }

  void _navigateMyFavoritePage() {
    // Navigate back to Login Page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyFavoritePage()),
    );
  }

  Future<void> _handleLogout() async {
    removeValue(AppConstants.userKey);
    navigateLoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$clubName Club'),
        backgroundColor: AppColors.textColor,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
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
                      Tab(
                        icon: Icon(Icons.local_activity),
                        child: Text(
                          'Home',
                          style: TextStyle(
                              fontSize: 10), // Set the desired text size here
                        ),
                      ),
                      Tab(
                        icon: Icon(Icons.local_activity),
                        child: Text(
                          'My Activity',
                          style: TextStyle(
                              fontSize: 10), // Set the desired text size here
                        ),
                      ),
                      Tab(
                        icon: Icon(Icons.add),
                        child: Text(
                          'Create Post',
                          style: TextStyle(
                              fontSize: 10), // Set the desired text size here
                        ),
                      ),
                      Tab(
                        icon: Icon(Icons.local_activity),
                        child: Text(
                          'Blog',
                          style: TextStyle(
                              fontSize: 10), // Set the desired text size here
                        ),
                      ),
                      Tab(
                        icon: Icon(Icons.local_activity),
                        child: Text(
                          'Club Space',
                          style: TextStyle(
                              fontSize: 10), // Set the desired text size here
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    navigateNotificationPage();
                  },
                ),
                _buildProfileDropdown(),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    navigateNotificationPage();
                  },
                ),
              ],
        automaticallyImplyLeading: !_isWeb(context),
      ),
      drawer: _isWeb(context) ? null : _buildDrawer(context),
      body: Container(
        color: Colors.grey[500], // Set body background color here
        child: _isWeb(context)
            ? TabBarView(
                controller: _tabController,
                children: _widgetOptions,
              )
            : _widgetOptions.elementAt(_tabController.index),
      ),
      bottomNavigationBar: _isWeb(context) ? null : _buildBottomNavigationBar(),
      floatingActionButton: !_isWeb(context)
          ? FloatingActionButton(
              onPressed: _onFabPressed,
              elevation: 10.0,
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Icon(
                Icons.add,
                size: 30.0,
                color: Colors.white,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
