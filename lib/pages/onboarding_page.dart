import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vaccination/pages/login.dart';
import 'package:vaccination/widgets/onboarding_card.dart'; // Import your custom widget

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    final List<Widget> _onBoardingPages = [
      OnboardingCard(
        image: "images/onb.png",
        title: 'Your journey to immunity starts here',
        description:
            'Protect yourself and others around you by taking the vaccines today.',
        buttonText: 'Get Started',
        onPressed: () {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 400),
            curve: Curves.linear,
          );
        },
      ),
      OnboardingCard(
        image: "images/im.png",
        title: 'Easily schedule and manage your vaccines',
        description:
            'Check with your device and schedule an appointment for vaccines.',
        buttonText: 'Next',
        onPressed: () {
          _pageController.animateToPage(
            2,
            duration: const Duration(milliseconds: 400),
            curve: Curves.linear,
          );
        },
      ),
      OnboardingCard(
        image: "images/ob11.png",
        title: 'Free access to request vaccine ID online',
        description:
            'You can now request a vaccine ID easily from your device.',
        buttonText: 'Next',
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LogIn()),
          );
        },
      ),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                children: _onBoardingPages,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LogIn()),
                );
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                side: const BorderSide(color: Colors.blue), // Border color
                backgroundColor: Colors.white, // Background color
                padding: const EdgeInsets.symmetric(
                    vertical: 16), // Increased height to match ElevatedButton
              ),
              child: SizedBox(
                width: 300, // Match width of ElevatedButton
                child: const Text(
                  'Skip',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                  textAlign: TextAlign.center, // Center the text
                ),
              ),
            ),
            const SizedBox(height: 40),
            SmoothPageIndicator(
              controller: _pageController,
              count: _onBoardingPages.length,
              effect: ExpandingDotsEffect(
                activeDotColor: const Color(0xFF17C2EC),
                dotColor: Theme.of(context).colorScheme.secondary,
              ),
              onDotClicked: (index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.linear,
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
