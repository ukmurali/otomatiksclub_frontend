import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class SwiperWidget extends StatefulWidget {
  const SwiperWidget({super.key});

  @override
  _SwiperWidgetState createState() => _SwiperWidgetState();
}

class _SwiperWidgetState extends State<SwiperWidget> {
  final List<String> cardTitles = [
    'Join Robotics',
    'Robotica',
    'Exhibit Your Skills'
  ]; // Sample titles
  final List<String> cardDescriptions = [
    'Achieve Academic Excellence and Shape Your Future',
    'VIT University, Vellore || 7th & 8th of Feb 2025',
    'Exhibit your talent at our nearest locations every Saturday'
  ]; // Sample descriptions
  final List<String> cardImages = [
    'assets/images/image1.png', // Replace with your image paths
    'assets/images/image2.png', // Change for card 2
    'assets/images/image3.png', // Change for card 3
  ];

  // List of colors for each card
  final List<Color> cardColors = [
    AppColors.bannerBackgroundOne, // Color for the first card
    AppColors.bannerBackgroundTwo, // Color for the second card
    Colors.green, // Color for the third card
  ];

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  Future<void> _launchURL() async {
    Uri url = Uri.parse('https://www.robotica.org.in/');
    if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // URL successfully launched
    } else {
      throw 'Could not launch $url';
    }
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return; // Ensure the widget is still mounted
      if (_pageController.hasClients) {
        // Check if the controller is attached to the PageView
        if (_currentIndex < cardTitles.length - 1) {
          _currentIndex++;
        } else {
          _currentIndex = 0;
        }
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      _startAutoScroll(); // Restart the auto scroll
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 125, // Adjust the height as necessary
          width: double.infinity, // Full width
          child: PageView.builder(
            controller: _pageController,
            itemCount: cardTitles.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) => Card(
              elevation: 2,
              color: cardColors[index],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: index == 1 // Check if it's card 2
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Center the content vertically
                        children: <Widget>[
                          Center(
                            // Center the image horizontally
                            child: Image.asset(
                              'assets/images/robotica_2025.jpg',
                              height: 55,
                            ),
                          ),
                          const SizedBox(height: 7),
                          // Row to hold description and button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  cardDescriptions[index],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  width:
                                      5), // Space between description and button
                              SizedBox(
                                width: 80,
                                height: 30,
                                child: TextButton(
                                  onPressed: () {_launchURL();},
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2.0,
                                      horizontal: 16.0,
                                    ),
                                  ),
                                  child: const Text(
                                    'Click here',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  cardTitles[index],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  cardDescriptions[index],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SizedBox(
                                  width: 80,
                                  height: 30,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2.0,
                                        horizontal: 16.0,
                                      ),
                                    ),
                                    child: const Text(
                                      'Click here',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 7),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(1),
                            child: Image.asset(
                              cardImages[index],
                              height: 100,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2), // Space between the swiper and the dots
        buildIndicator(),
      ],
    );
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: _currentIndex,
        count: cardTitles.length,
        effect: ExpandingDotsEffect(
          dotHeight: 10,
          dotWidth: 10,
          activeDotColor: AppColors.primaryColor,
          dotColor: Colors.grey.withOpacity(0.5),
        ),
      );
}
