import 'package:flutter/material.dart';
import 'package:vfstr/screens/home_screen.dart';
import 'package:vfstr/screens/user_add_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vfstr/constants/serverurl.dart';

class CredLoginScreen extends StatefulWidget {
  @override
  _CredLoginScreenState createState() => _CredLoginScreenState();
}

class _CredLoginScreenState extends State<CredLoginScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adminIdController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();

  // void _login() {
  //   String employeeId = _employeeIdController.text.trim();
  //   String password = _passwordController.text.trim();

  //   if (employeeId.isNotEmpty && password.isNotEmpty) {
  //     // TODO: Validate login credentials (API integration)
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => HomeScreen()),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Please enter Employee ID and Password")),
  //     );
  //   }
  // }

  Future<void> _login() async {
    String employeeId = _employeeIdController.text.trim();
    String password = _passwordController.text.trim();

    if (employeeId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter Employee ID and Password")),
      );
      return;
    }

    try {
      var uri = Uri.parse("$serverurl/api/login/");
      
      var response = await http.post(
        uri,
        body: jsonEncode({
          'employee_id': employeeId,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Navigate to HomeScreen if login is successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        var responseBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        String errorMessage = responseBody.containsKey('detail')
            ? responseBody['detail']
            : "Login failed";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }



  void _showAdminLoginDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Admin Login"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _adminIdController,
                decoration: InputDecoration(labelText: "Admin ID"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _adminPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String adminId = _adminIdController.text.trim();
                String password = _adminPasswordController.text.trim();
                
                if (adminId.isNotEmpty && password.isNotEmpty) {
                  // TODO: Validate admin credentials (API integration)

                  // Close the dialog
                  Navigator.pop(context);

                  // Navigate to User Add Screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UserAddScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter Admin ID and Password")),
                  );
                }
              },
              child: Text("Login"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Employee Login",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _employeeIdController,
                    decoration: InputDecoration(labelText: "Employee ID"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Password"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text("Login"),
                  ),
                ],
              ),
            ),
          ),

          // Admin Login Button in Top-Right Corner
          Positioned(
            top: 40,
            right: 20,
            child: ElevatedButton(
              onPressed: _showAdminLoginDialog,
              child: Text("Admin Login"),
            ),
          ),
        ],
      ),
    );
  }
}
