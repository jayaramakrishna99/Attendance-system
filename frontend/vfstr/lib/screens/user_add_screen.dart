import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vfstr/constants/serverurl.dart';
import 'package:vfstr/screens/cred_login_screen.dart';

class UserAddScreen extends StatefulWidget {
  @override
  _UserAddScreenState createState() => _UserAddScreenState();
}

class _UserAddScreenState extends State<UserAddScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _getEmployeeIdController = TextEditingController();
  String? retrievedPassword;

  Future<void> _addEmployee() async {
    String employeeId = _employeeIdController.text.trim();
    String name = _nameController.text.trim();
    String password = _passwordController.text.trim();

    if (employeeId.isEmpty || name.isEmpty || password.isEmpty) {
      _showDialog("Error", "Please fill in all fields!");
      return;
    }

    try {
      var uri = Uri.parse("$serverurl/api/add-employee/");

      var response = await http.post(
        uri,
        body: {
          'employee_id': employeeId,
          'name': name,
          'password': password,
        },
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        _showDialog("Success", "Employee added successfully!");
        _employeeIdController.clear();
        _nameController.clear();
        _passwordController.clear();
      } else {
        _showDialog("Error", "Failed to add employee!");
      }
    } catch (e) {
      _showDialog("Error", "Error: $e");
    }
  }

  Future<void> _getEmployeeDetails() async {
    String employeeId = _getEmployeeIdController.text.trim();  // Use the correct controller

    if (employeeId.isEmpty) {
      _showDialog("Error", "Please enter Employee ID");
      return;
    }

    try {
      var uri = Uri.parse("$serverurl/api/get-employee-details/?employee_id=$employeeId");
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        String name = responseBody['name'];
        String password = responseBody['password'];

        _showDialog("Employee Details", "Employee Name: $name\nPassword: $password");
      } else {
        _showDialog("Error", "Failed to get employee details!");
      }
    } catch (e) {
      _showDialog("Error", "Error: $e");
    }
  }


  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CredLoginScreen()), 
    );
  }

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Employee"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _employeeIdController,
                decoration: InputDecoration(labelText: "Employee ID"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
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
                _addEmployee();
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showGetEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Get Employee Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _getEmployeeIdController,
                decoration: InputDecoration(labelText: "Employee ID"),
              ),
              SizedBox(height: 10),
              retrievedPassword != null
                  ? Text("Password: $retrievedPassword")
                  : SizedBox.shrink(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
            ElevatedButton(
              onPressed: () {
                _getEmployeeDetails();
              },
              child: Text("Get"),
            ),
          ],
        );
      },
    );
  }

  // A helper function to show the dialog with a message
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 24),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _showAddEmployeeDialog,
              child: Text("Add Employee"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 60),  // Set both width and height to the same value for a square
                padding: EdgeInsets.all(0),   // Remove padding so the button is exactly the size defined
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Square corners
                ),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _showGetEmployeeDialog,
              child: Text("Get Employee Details"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 60),  // Square shape
                padding: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
