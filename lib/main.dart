import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stem_club/constants.dart';
import 'package:stem_club/screens/dashboard.dart';
import 'package:stem_club/screens/onboarding_page.dart';
import 'package:stem_club/utils/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      await Future.delayed(const Duration(seconds: 10)); // Add a 2-second delay

      Map<String, dynamic>? user = await getValue(AppConstants.userKey);
      Map<String, dynamic>? userMap = user?['user'];

      setState(() {
        _isLoggedIn = userMap != null;
        _isLoading = false; // Set loading to false once check is complete
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      // Display loading indicator, OnboardingPage, or DashboardPage based on state
      home: _isLoading
          ? Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Add the logo here
                    Image.asset(
                      'assets/images/otomatiks_logo.png',
                    ),
                    const SizedBox(
                        height: 20), // Space between logo and loading spinner
                    const Text(
                      'Welcome OTOMATKS Club',
                    ),
                  ],
                ),
              ),
            )
          : _isLoggedIn
              ? const DashboardPage()
              : const OnboardingPage(),
    );
  }
}
