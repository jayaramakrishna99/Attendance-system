import 'package:flutter/material.dart';
import 'package:vfstr/screens/cred_login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 241, 230, 1), 
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(81, 97, 91, 1), 
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Color.fromRGBO(245, 241, 230, 1),
              size: 30, 
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CredLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to VFSTR Attendance System',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(81, 97, 91, 1), 
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
