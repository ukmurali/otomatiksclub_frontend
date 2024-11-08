import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:otomatiksclub/api/user_service/api_user_service.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/screens/club_selection_page.dart';
import 'package:otomatiksclub/utils/utils.dart';
import 'package:otomatiksclub/widgets/custom_snack_bar.dart';
import 'package:otomatiksclub/widgets/loading_indicator.dart';

class WelcomeDialogPage extends StatefulWidget {
  const WelcomeDialogPage({super.key});

  @override
  _WelcomeDialogPageState createState() => _WelcomeDialogPageState();
}

class _WelcomeDialogPageState extends State<WelcomeDialogPage> {
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog(context);
    });
  }

  Future<void> _join() async {
    setState(() => _isLoading = true);
    final response = await ApiUserService.joinUser();

    final responseBody = response['body'] as String;
    if (!mounted) return;

    setState(() => _isLoading = false);
    if ((response['statusCode'] != 200)) {
      CustomSnackbar.showSnackBar(context, responseBody, false);
      return;
    }

    final result = jsonDecode(response['body']);
    await storeValue(AppConstants.userKey, result);
    _moveToClubListPage();
  }

  void _moveToClubListPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const ClubSelectionPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _showWelcomeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            AbsorbPointer(
              absorbing: _isLoading,
              child: AlertDialog(
                title: const Text('Welcome Otomatiks Club',
                    textAlign: TextAlign.center),
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
                      'Joining Club Points',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '100',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _join();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.textColor,
                      ),
                      child: const Text('Join'),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading) const LoadingIndicator(),
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
