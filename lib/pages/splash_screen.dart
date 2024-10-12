import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_page.dart'; // Import the OnboardingPage here

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 3 seconds then navigate to OnboardingPage
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            // App logo or any image
            Center(
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Make the container circular
                  color: Colors.white, // Background color of the container
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5), // Shadow color
                      blurRadius: 10, // Softness of the shadow
                      spreadRadius: 5, // Size of the shadow
                      offset: Offset(0, 4), // Position of the shadow (x, y)
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'images/splshr.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover, // Adjust image fit
                  ),
                ),
              ),
            ),
            Center(
              child: Image.asset(
                'images/lsk.png',
                height: 200,
                width: 200,
                fit: BoxFit.cover, // Adjust image fit
              ),
            ),

            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}