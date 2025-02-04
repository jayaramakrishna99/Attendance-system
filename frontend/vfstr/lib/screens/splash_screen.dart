import 'package:flutter/material.dart';
import 'package:vfstr/screens/cred_login_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _logoOpacity = 0.0; // Logo fade-in opacity
  double _textOpacity = 0.0; // Text fade-in opacity

  @override
  void initState() {
    super.initState();

    // Fade in the logo
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _logoOpacity = 1.0;
      });
    });

    // Fade in the text after the logo appears
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _textOpacity = 1.0;
      });
    });

    // Navigate to the next screen after a delay
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CredLoginScreen()), // Replace with your home screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with fade-in animation
            AnimatedOpacity(
              opacity: _logoOpacity,
              duration: Duration(seconds: 2),
              child: Image.asset(
                'assets/logo.png', // Ensure logo.png is in the assets folder
                width: 150,
                height: 150,
              ),
            ),

            SizedBox(height: 20), // Space between logo and text

            // Text with fade-in animation
            AnimatedOpacity(
              opacity: _textOpacity,
              duration: Duration(seconds: 2),
              child: Text(
                "VFSTR Attendance System",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
