// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:vfstr/screens/cred_login_screen.dart';

// class WelcomeScreen extends StatefulWidget {
//   @override
//   _WelcomeScreenState createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen> {
//   bool showInstructions = false; // Track whether to show instructions

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onVerticalDragUpdate: (details) {
//         setState(() {
//           if (details.primaryDelta! < -10) {
//             showInstructions = true; // Swipe up: Show instructions
//           } else if (details.primaryDelta! > 10) {
//             showInstructions = false; // Swipe down: Show welcome message
//           }
//         });
//       },
//       child: Scaffold(
//         backgroundColor: Color.fromRGBO(245, 241, 230, 1),
//         appBar: AppBar(
//           backgroundColor: Color.fromRGBO(81, 97, 91, 1),
//           elevation: 0,
//           actions: [
//             IconButton(
//               icon: Icon(
//                 Icons.logout,
//                 color: Color.fromRGBO(245, 241, 230, 1),
//                 size: 30,
//               ),
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => CredLoginScreen()),
//                 );
//               },
//             ),
//           ],
//         ),
//         body: AnimatedSwitcher(
//           duration: Duration(milliseconds: 500),
//           child: showInstructions ? _buildInstructions() : _buildWelcomeMessage(),
//         ),
//       ),
//     );
//   }

//   /// **Welcome Message UI**
//   Widget _buildWelcomeMessage() {
//     return Column(
//       key: ValueKey(1),
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Center(
//           child: Image.asset(
//             'assets/full_logo.png',
//             height: 100,
//             fit: BoxFit.contain,
//           ),
//         ),
//         SizedBox(height: 20),
//         Center(
//           child: Text(
//             'Welcome to VFSTR Attendance System',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Color.fromRGBO(81, 97, 91, 1),
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//         SizedBox(height: 20),
        
//         /// **Lottie Animation for Swipe Up**
//         Center(
//           child: Column(
//             children: [
//               Lottie.asset(
//                 'assets/animations/swipe-up.json',
//                 height: 200,
//                 width: 200,
//                 fit: BoxFit.contain,
//               ),
//               SizedBox(height: 5),
//               Text(
//                 'Swipe up for instructions',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   /// **Instructions UI**
//   Widget _buildInstructions() {
//     return SingleChildScrollView(
//       key: ValueKey(2),
//       padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionTitle('📌 How to Use the Employee Attendance System'),

//           _buildSubTitle('1️⃣ Registering as a New User'),
//           _buildBulletPoint('If you are not registered, tap the Register icon in the bottom right corner.'),
//           _buildBulletPoint('This will take you to the Register Page.'),
//           _buildBulletPoint('Enter your Employee ID and Name.'),
//           _buildBulletPoint('Tap the 📷 Camera Icon to capture your image.'),
//           _buildBulletPoint('Click Register to complete the process.'),
//           _buildBulletPoint('If you need to update your details, click the Update button.'),
//           SizedBox(height: 20),

//           _buildSubTitle('2️⃣ Marking Your Attendance'),
//           _buildBulletPoint('Tap the Mark Attendance Button in the bottom center of the screen.'),
//           _buildBulletPoint('Enter your Employee ID.'),
//           _buildBulletPoint('Tap the 📷 Camera Icon to capture your image.'),
//           _buildBulletPoint('Click Mark Attendance to submit.'),
//           SizedBox(height: 20),

//           _buildSubTitle('📍 Important Notes:'),
//           _buildBulletPoint('✅ You must be within the college premises to mark attendance.'),
//           _buildBulletPoint('✅ Ensure you are connected to the college\'s Local Area Network (LAN).'),
//           SizedBox(height: 20),

//           Center(
//             child: Text(
//               '⬇️ Swipe down to return to the Welcome screen',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String text) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 10),
//       child: Text(
//         text,
//         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
//       ),
//     );
//   }

//   Widget _buildSubTitle(String text) {
//     return Padding(
//       padding: EdgeInsets.only(top: 15, bottom: 5),
//       child: Text(
//         text,
//         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
//       ),
//     );
//   }

//   Widget _buildBulletPoint(String text) {
//     return Padding(
//       padding: EdgeInsets.only(left: 10, top: 5),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vfstr/screens/cred_login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool showInstructions = false; // Track whether to show instructions

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
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! < -10) {
            setState(() {
              showInstructions = true; // Swipe up: Show instructions
            });
          }
        },
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: showInstructions ? _buildInstructions() : _buildWelcomeMessage(),
        ),
      ),
    );
  }

  /// **Welcome Message UI**
  Widget _buildWelcomeMessage() {
    return Column(
      key: ValueKey(1),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Image.asset(
            'assets/full_logo.png',
            height: 100,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 20),
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

        /// **Lottie Animation for Swipe Up**
        Center(
          child: Column(
            children: [
              Lottie.asset(
                'assets/animations/swipe-up.json',
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 1),
              Text(
                'Swipe up for instructions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// **Instructions UI**
  Widget _buildInstructions() {
    return SingleChildScrollView(
      key: ValueKey(2),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// **Back Button**
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  showInstructions = false; // Go back to welcome screen
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(81, 97, 91, 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Back to Home',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 20),

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
