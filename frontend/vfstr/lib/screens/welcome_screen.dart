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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// **Logo Image**
              Center(
                child: Image.asset(
                  'assets/full_logo.png', // Ensure this image exists in assets
                  height: 100, // Adjust height as needed
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),
              /// **Welcome Message**
              Center(
                child: Text(
                  'Welcome to VFSTR Attendance System',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(81, 97, 91, 1),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),

              /// **Instructions**
              _buildSectionTitle('📌 How to Use the Employee Attendance System'),

              _buildSubTitle('1️⃣ Registering as a New User'),
              _buildBulletPoint('If you are not registered, tap the Register icon in the bottom right corner.'),
              _buildBulletPoint('This will take you to the Register Page.'),
              _buildBulletPoint('Enter your Employee ID and Name.'),
              _buildBulletPoint('Tap the 📷 Camera Icon to capture your image.'),
              _buildBulletPoint('Click Register to complete the process.'),
              _buildBulletPoint('If you need to update your details, click the Update button.'),
              SizedBox(height: 20),

              _buildSubTitle('2️⃣ Marking Your Attendance'),
              _buildBulletPoint('Tap the Mark Attendance Button in the bottom center of the screen.'),
              _buildBulletPoint('Enter your Employee ID.'),
              _buildBulletPoint('Tap the 📷 Camera Icon to capture your image.'),
              _buildBulletPoint('Click Mark Attendance to submit.'),
              SizedBox(height: 20),

              _buildSubTitle('📍 Important Notes:'),
              _buildBulletPoint('✅ You must be within the college premises to mark attendance.'),
              _buildBulletPoint('✅ Ensure you are connected to the college\'s Local Area Network (LAN).'),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// **Helper functions for UI formatting**
  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildSubTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 15, bottom: 5),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
