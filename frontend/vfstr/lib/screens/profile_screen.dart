import 'package:flutter/material.dart';
import 'dart:typed_data';

class ProfileScreen extends StatelessWidget {
  final String facultyName;
  final Uint8List? profileImage;

  const ProfileScreen({Key? key, required this.facultyName, required this.profileImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(81, 97, 91, 1),
      ),
      body: SingleChildScrollView( // Prevent overflow
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align elements at the top
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30), // Adjust spacing from top
            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundImage: profileImage != null
                    ? MemoryImage(profileImage!)
                    : AssetImage('assets/default_profile.png') as ImageProvider,
                backgroundColor: Colors.grey[400],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                facultyName,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color.fromRGBO(81, 97, 91, 1)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
