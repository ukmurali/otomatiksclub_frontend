import 'package:flutter/material.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/widgets/custom_button.dart';
import 'package:otomatiksclub/widgets/swiper_view.dart';
import 'package:otomatiksclub/screens/login_page.dart'; // Import the LoginPage

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      body: SingleChildScrollView(
        // To avoid overflow on smaller screens
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/otomatiks_logo.png', // Replace with your image path
              height: 100.0, // Adjust height as needed
            ),
            const SizedBox(height: 20), // Spacing before swiper
            const SwiperView(
              imagePaths: [
                'assets/images/image1.png',
                'assets/images/image2.png',
                'assets/images/image3.png',
              ],
              captions: [
                'Welcome to ${AppConstants.appName}, where STEM-based creativity meets innovation!',
                'Experience hands-on learning that turns ideas into reality!',
                'Join our club and shape the future together!',
              ],
            ),
            const SizedBox(height: 40), // Spacing before the button
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: isWeb ? 400 : double.infinity, // Wider button for web
                  child: CustomButton(
                    buttonText: 'Get Started',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    isWeb: isWeb,
                    isIcon: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
