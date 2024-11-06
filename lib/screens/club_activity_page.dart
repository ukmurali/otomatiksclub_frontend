import 'package:flutter/material.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/screens/club_dialog.dart';

class ClubActivityPage extends StatelessWidget {
  const ClubActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/image2.png', // Path to your asset image
              width: 100, // Set the width of the image
              height: 100, // Set the height of the image
              fit: BoxFit.cover, // Adjust the fit as needed
            ),
            const SizedBox(height: 16), // Spacing between the image and text
            const Text(
              'No club available yet.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Start by creating your first club or join an existing one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FloatingActionButton.extended(
              onPressed: () {
                _showAddClubDialog(context); // Show dialog on button press
              },
              label: const Text(
                'Add Club',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 18,
                ),
              ),
              icon: const Icon(
                Icons.add,
                color: Colors.black, // Custom icon color
              ),
              backgroundColor: Colors.white, // Custom background color
            ),
            const SizedBox(height: 16), // Spacing between buttons
            ElevatedButton(
              onPressed: () {
                _showJoinClubDialog(context); // Show dialog on button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primaryColor, // Button background color
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12), // Button padding
                elevation: 5,
              ),
              child: const Text(
                'Join Club',
                style: TextStyle(
                  color: Colors.white, // Button text color
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddClubDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClubDialog(
          title: 'Create a New Club',
          buttonText: 'Create Club',
          onSubmit: (clubName) {
            // Perform action to add the club
            // Optionally: Display a message or update the UI
          },
          suggestions: const [], // Pass an empty list or relevant suggestions
        );
      },
    );
  }

  void _showJoinClubDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClubDialog(
          title: 'Join a Club',
          buttonText: 'Join Club',
          onSubmit: (clubName) {
            // Perform action to join the club
            // Optionally: Display a message or update the UI
          },
          suggestions: _getClubSuggestions(), // Provide a list of club names
        );
      },
    );
  }

  List<String> _getClubSuggestions() {
    // Replace with the actual logic to fetch club suggestions
    return ['Club A', 'Club B', 'Club C'];
  }
}
