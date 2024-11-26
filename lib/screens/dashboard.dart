import 'package:flutter/material.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/screens/admin_post_page.dart';
import 'package:otomatiksclub/screens/club_selection_page.dart';
import 'package:otomatiksclub/screens/blog_page.dart';
import 'package:otomatiksclub/screens/home_page.dart';
import 'package:otomatiksclub/screens/my_favorite_page.dart';
import 'package:otomatiksclub/screens/notification_page.dart';
import 'package:otomatiksclub/screens/post_page.dart';
import 'package:otomatiksclub/screens/profile_page.dart';
import 'package:otomatiksclub/screens/login_page.dart';
import 'package:otomatiksclub/screens/share_friends_dialog_page.dart';
import 'package:otomatiksclub/utils/utils.dart';
import 'package:otomatiksclub/screens/create_post_dialog_mobile.dart';
import 'package:otomatiksclub/widgets/loading_indicator.dart';

class DashboardPage extends StatefulWidget {
  final int initialTabIndex;
  const DashboardPage({super.key, this.initialTabIndex = 0});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late String mobileNumber = "";
  late String referralCode = "";
  late Map<String, dynamic>? user;
  late String username = "";
  late String role = "";
  late String dateOfdobBirth;
  late String clubLevel = "";
  late String clubName = "Club";
  late String clubId = "";
  late String postAction = "Post";

  List<Widget> _widgetOptions = <Widget>[];

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
      length: 5,
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
      role = userMap['role'];
      referralCode = userMap['referralCode'];
      dateOfdobBirth = userMap['dateOfBirthString'];
      clubLevel = getAgeGroup(dateOfdobBirth);
      user = userMap;
      clubName = clubData?['name'];
      clubId = clubData?['id'];

      // Define _widgetOptions based on role
      _widgetOptions = [
        const HomePage(),
        role.isNotEmpty && role == 'ADMIN'
            ? const AdminPostPage()
            : const MyPostsPage(),
        const CreatePostDialogMobile(),
        const BlogPage(),
        const ClubSelectionPage(),
      ];
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
    if (index == 4) {
      // "Club Space" is the last item in the BottomNavigationBar
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const ClubSelectionPage()), // Navigate to Club Space page
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
    if (role == 'STUDENT') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreatePostDialogMobile(role: role)),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: const Text(
              'Choose an Option',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (role == 'TUTOR')
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: const Text('Create Post Myself'),
                    onTap: () {
                      Navigator.pop(context); // Close the dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                 CreatePostDialogMobile(role: role)),
                      );
                    },
                  ),
                if (role == 'TUTOR')
                  const Divider(),
                ListTile(
                  leading: const Icon(Icons.group, color: Colors.green),
                  title: const Text('Create Post to Student'),
                  onTap: () {
                    Navigator.pop(context); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  CreatePostDialogMobile(role: role)),
                    );
                  },
                ),
                const Divider(),
                if (role == 'ADMIN')
                  ListTile(
                    leading: const Icon(Icons.article, color: Colors.purple),
                    title: const Text('Create Blog'),
                    onTap: () {
                      postAction = "Blog";
                      Navigator.pop(context); // Close the dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  CreatePostDialogMobile(role: role, postAction: postAction)),
                      );
                    },
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    }
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
                  (role.isNotEmpty && role == 'ADMIN')
                      ? 'Admin'
                      : clubLevel.isNotEmpty
                          ? clubLevel
                          : "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                if (role.isNotEmpty && role == 'STUDENT')
                  Text(
                    referralCode.isNotEmpty ? 'Your Code: $referralCode' : "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
              ],
            ),
          ),
          if (role.isNotEmpty && role == 'STUDENT')
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Invite Friends'),
              onTap: () {
                _navigateInvitePage();
              },
            ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              _navigateProfilePage();
            },
          ),
          if (role.isNotEmpty && role == 'STUDENT')
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

  void _navigateInvitePage() {
    // Navigate back to Login Page
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ShareFriendsDialogPage(referralCode: referralCode)),
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
    removeValue(AppConstants.clubKey);
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
                _buildProfileDropdown(),
              ]
            : [],
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
            : _widgetOptions.isNotEmpty
                ? _widgetOptions.elementAt(_tabController.index)
                : const Center(child: LoadingIndicator()),
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
