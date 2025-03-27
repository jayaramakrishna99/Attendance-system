import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';
import 'package:vfstr/screens/cred_login_screen.dart';
import 'package:vfstr/screens/instructions_screen.dart';
import 'package:vfstr/constants/serverurl.dart';
import 'package:vfstr/screens/profile_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final String facultyId;

  const WelcomeScreen({Key? key, required this.facultyId}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool showInstructions = false;
  Uint8List? _profileImage;
  String facultyName = "";

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      var uri = Uri.parse("$serverurl/api/get_faculty_image/${widget.facultyId}");
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          facultyName = data['name'];  // Store faculty name
          _profileImage = base64Decode(data['image_base64']);
        });
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
}

  // void _showProfileScreen() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ProfileScreen(
  //         facultyName: facultyName, // Pass faculty name
  //         profileImage: _profileImage, // Pass image
  //       ),
  //     ),
  //   );
  // }
  void _showProfileScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 100),
        pageBuilder: (context, animation, secondaryAnimation) => ProfileScreen(
          facultyName: facultyName, 
          profileImage: _profileImage,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0.0), // Start from right
              end: Offset.zero, // Move to center
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 241, 230, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(81, 97, 91, 1),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: _showProfileScreen,
            child: CircleAvatar(
              radius: 25,
              backgroundImage: _profileImage != null
                  ? MemoryImage(_profileImage!) 
                  : AssetImage('assets/default_profile.png') as ImageProvider, 
            ),
          ),
        ),
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
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! < -10) {
            setState(() {
              showInstructions = true;
            });
          }
        },
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: showInstructions
              ? InstructionsScreen(onBack: () {
                  setState(() {
                    showInstructions = false;
                  });
                })
              : _buildWelcomeMessage(),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      key: ValueKey(1),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Center(
            child: Image.asset(
              'assets/full_logo.png',
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                SizedBox(height: 20),
                Lottie.asset(
                  'assets/animations/swipe-up.json',
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 5),
                Text(
                  'Swipe up for instructions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
