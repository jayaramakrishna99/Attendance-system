import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome to VFSTR Attendance System',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            '"Attendance is the bridge between education and excellence."',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
