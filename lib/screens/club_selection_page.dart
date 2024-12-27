import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:otomatiksclub/api/club_service/api_club_service.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/screens/dashboard.dart';
import 'package:otomatiksclub/utils/user_auth_data.dart';
import 'package:otomatiksclub/utils/utils.dart';
import 'package:otomatiksclub/widgets/custom_snack_bar.dart';
import 'package:otomatiksclub/widgets/no_internet_view.dart';

// Sample Club Model
class Club {
  final String id;
  final String name;
  final String assetImagePath;

  Club({required this.id, required this.name, required this.assetImagePath});

  // Convert Club object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'assetImagePath': assetImagePath,
    };
  }

  // Factory method to create Club object from Map
  factory Club.fromMap(Map<String, dynamic> map) {
    return Club(
      id: map['id'],
      name: map['name'],
      assetImagePath: map['assetImagePath'],
    );
  }
}

class ClubSelectionPage extends StatefulWidget {
  const ClubSelectionPage({super.key});

  @override
  _ClubSelectionPageState createState() => _ClubSelectionPageState();
}

class _ClubSelectionPageState extends State<ClubSelectionPage> {
  List<Club> clubs = [];

  @override
  void initState() {
    super.initState();
    _fetchClubs();
  }

  Future<void> _fetchClubs() async {
    final response = await ApiClubService.fetchClubs();
    if (response != null && response['statusCode'] == 200) {
      final responseBody = response['body'];
      final parsedResponse = jsonDecode(responseBody);
      setState(() {
        parsedResponse.forEach((club) {
          String id = club['id'];
          String name = club['name'];
          String assetImagePath;
          switch (name) {
            case 'Robotics':
              assetImagePath = 'assets/images/image1.png';
              break;
            case 'Abacus':
              assetImagePath = 'assets/images/abacus.png';
              break;
            default:
              assetImagePath = 'assets/images/image2.png';
          }
          clubs.add(Club(id: id, name: name, assetImagePath: assetImagePath));
        });
      });
    }
     if (response?['body'] == 'Exception: No internet connection available') {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NoInternetPage(),
              ),
            );
          }
        }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose your ClubSpace',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 2; // Default for mobile

            // Increase the number of columns for larger screens
            if (constraints.maxWidth > 1200) {
              crossAxisCount = 6; // Desktop
            } else if (constraints.maxWidth > 800) {
              crossAxisCount = 4; // Tablet
            }

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio:
                    0.8, // Adjust height-to-width ratio of each card
              ),
              itemCount: clubs.length,
              itemBuilder: (context, index) {
                final club = clubs[index];
                return ClubCard(club: club);
              },
            );
          },
        ),
      ),
    );
  }
}

class ClubCard extends StatelessWidget {
  final Club club;

  const ClubCard({super.key, required this.club});

  Future<void> _handleClubTap(BuildContext context) async {
    UserAuthData userAuthData = await getUserIdAndAuthToken();
    String? role = userAuthData.role;
    if (role == AppConstants.STD) {
      try {
        // Call API with club ID
        final response = await ApiClubService.createClubUser(club.id);
        if (response['statusCode'] != 200) {
          CustomSnackbar.showSnackBar(
              context, 'Please try again after sometime', false);
        }
        await storeValue(AppConstants.clubKey, club.toMap());
        // Navigate to DashboardPage on successful response
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
        );
      } catch (e) {
        CustomSnackbar.showSnackBar(
            context, 'Please try again after sometime', false);
      }
    } else {
      await storeValue(AppConstants.clubKey, club.toMap());
      // Navigate to DashboardPage on successful response
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleClubTap(context), // Call the method on tap
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  club.assetImagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              club.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
