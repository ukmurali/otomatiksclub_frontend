import 'package:flutter/material.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/screens/dashboard.dart';
import 'package:otomatiksclub/utils/utils.dart';

class ShareFriendsDialogPage extends StatefulWidget {
  final String referralCode;
  const ShareFriendsDialogPage({super.key, this.referralCode = ""});

  @override
  _ShareFriendsDialogPageState createState() => _ShareFriendsDialogPageState();
}

class _ShareFriendsDialogPageState extends State<ShareFriendsDialogPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog(context);
    });
  }

  void _showWelcomeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            AlertDialog(
              title: const Text('Invite Friends', textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Centered Image
                  Image.asset(
                    'assets/images/logo.png', // Replace with your image path
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 20),
                  // Centered Text Below the Image
                  const Text(
                    'Invite your friends and earn 50 Club points!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Distribute buttons across
                  children: [
                    // Cancel Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DashboardPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.grey, // Neutral color for cancel
                        foregroundColor: AppColors.textColor,
                      ),
                      child: const Text('Cancel'),
                    ),
                    // Share Button
                    ElevatedButton(
                      onPressed: () {
                        shareInvite(widget.referralCode); // Share logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.textColor,
                      ),
                      child: const Text('Share'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(), // Empty container as no button is needed
      ),
    );
  }
}
