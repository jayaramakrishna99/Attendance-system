import 'package:flutter/material.dart';
import 'package:vfstr/screens/cred_login_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _logoOpacity = 0.0;
  double _textOpacity = 0.0; 
  double _creditsOpacity = 0.0; 

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _logoOpacity = 1.0;
      });
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _textOpacity = 1.0;
      });
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _creditsOpacity = 1.0;
      });
    });

    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CredLoginScreen()), 
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _logoOpacity,
                  duration: Duration(seconds: 2),
                  child: Image.asset(
                    'assets/logo.png', 
                    width: 150,
                    height: 150,
                  ),
                ),

                SizedBox(height: 20),

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

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _creditsOpacity,
              duration: Duration(seconds: 2),
              child: Column(
                children: [
                  Text(
                    "Developed by:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    "Surya | Jayarama Krishna | Mahesh | Manoj",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Guided by: Dr. D. Venkatesulu (Dean, ACSE)", 
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
