import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:otomatiksclub/colors/app_colors.dart';

class SwiperView extends StatefulWidget {
  final List<String> imagePaths;
  final List<String> captions;

  const SwiperView({super.key, required this.imagePaths, required this.captions});

  @override
  _SwiperViewState createState() => _SwiperViewState();
}

class _SwiperViewState extends State<SwiperView> {
  int activeIndex = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 800;
    final double imageHeight = isWeb ? 250 : 200;

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _controller,
          itemCount: widget.imagePaths.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            return SizedBox( // Use SizedBox instead of Expanded
              height: imageHeight, // Set a specific height for the slider
              child: Column(
                children: [
                  SizedBox(
                    height: imageHeight,
                    child: Image.asset(
                      widget.imagePaths[index],
                      fit: BoxFit.contain, // Use BoxFit.contain for web view
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: SingleChildScrollView( // Allow content to be scrollable
                      child: Text(
                        widget.captions[index],
                        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          options: CarouselOptions(
            height: isWeb ? 350.0 : 300.0,  // Adjust height based on the platform
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            aspectRatio: 2.0,
            initialPage: 0,
            onPageChanged: (index, reason) {
              setState(() {
                activeIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        buildIndicator(),
      ],
    );
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: widget.imagePaths.length,
        effect: ExpandingDotsEffect(
          dotHeight: 10,
          dotWidth: 10,
          activeDotColor: AppColors.primaryColor,
          dotColor: Colors.grey.withOpacity(0.5),
        ),
        onDotClicked: (index) {
          _controller.animateToPage(index);
        },
      );
}