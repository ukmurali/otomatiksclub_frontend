import 'package:flutter/material.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:stem_club/constants.dart';
import 'package:stem_club/widgets/custom_button.dart';
import 'package:stem_club/widgets/swiper_view.dart';
import 'package:stem_club/screens/login_page.dart'; // Import the LoginPage

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width >
        600; // Determine if the platform is web or mobile

    return Scaffold(
      appBar: const CustomAppBar(), // Use the custom AppBar widget
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
          const SizedBox(height: 40), // Add spacing between swiper and button
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Disable default leading icon
      title: const Row(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center content horizontally
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center content vertically
        children: [
          // Logo on the left
          // Add spacing between the logo and the app name
          // App name in the center
          Column(
            mainAxisSize: MainAxisSize
                .min, // Ensure the column takes only as much space as needed
            children: [
              Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 30.0, // Adjust the size if needed
                  fontWeight: FontWeight.bold, // Make the title bold
                ),
                textAlign:
                    TextAlign.center, // Center the text within the title widget
              ),
              Text(
                'Inspiring the next generation', // Add your small text here
                style: TextStyle(
                  fontSize: 10.0, // Smaller font size for the text below
                  color: AppColors
                      .primaryColor, // Optional: Change the color of the small text
                ),
              ),
              SizedBox(
                  height:
                      10.0), // Add spacing between the title and the small text
            ],
          ),
        ],
      ),
      centerTitle: true, // Ensure the title is centered in the AppBar
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(
      150.0); // Increase the height of the AppBar to fit both texts
}
