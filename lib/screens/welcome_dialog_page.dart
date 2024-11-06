import 'package:flutter/material.dart';

class WelcomeDialogPage extends StatefulWidget {
  const WelcomeDialogPage({super.key});

  @override
  _WelcomeDialogPageState createState() => _WelcomeDialogPageState();
}

class _WelcomeDialogPageState extends State<WelcomeDialogPage> {
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Welcome Otomatiks Club', textAlign: TextAlign.center),
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
                'Joining Club Points - 100',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Ok'),
              ),
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