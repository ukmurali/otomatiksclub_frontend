import 'package:flutter/material.dart';
import 'package:stem_club/constants.dart';
import 'package:stem_club/screens/dashboard.dart';
import 'package:stem_club/screens/onboarding_page.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    Map<String, dynamic>? user = await getValue(AppConstants.userKey);
    if (user != null) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        textTheme: GoogleFonts.titilliumWebTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      // If _isLoggedIn is true, show DashboardPage, otherwise show OnboardingPage
      home: _isLoggedIn ? const DashboardPage() : const OnboardingPage(),
    );
  }
}
