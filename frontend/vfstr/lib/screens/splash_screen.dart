import 'package:flutter/material.dart';
import 'package:vfstr/screens/home_screen.dart'; 
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _logoOpacity = 0.0; // For fade-in animation
  double _textPosition = 100; // Initial offset for slide-up

  @override
  void initState() {
    super.initState();

    // Start animations with a delay
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _logoOpacity = 1.0; // Fade in the logo
      });
    });

    // Animate the text after the logo fades in
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _textPosition = 20; // Slide up the text from the bottom
      });
    });

    // Navigate to the next screen after a delay
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()), // Replace with your home screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background color
          Container(
            color: Colors.white,
          ),

          // Logo at the center
          Center(
            child: AnimatedOpacity(
              opacity: _logoOpacity,
              duration: Duration(seconds: 2),
              child: Image.asset(
                'assets/logo.png', // Make sure logo.png is in the assets folder
                width: 150, // Adjust size as needed
                height: 150,
              ),
            ),
          ),

          // Sliding text from the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedPadding(
              padding: EdgeInsets.only(bottom: _textPosition),
              duration: Duration(seconds: 2),
              curve: Curves.easeOut,
              child: Text(
                "VFSTR Attendance System",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
