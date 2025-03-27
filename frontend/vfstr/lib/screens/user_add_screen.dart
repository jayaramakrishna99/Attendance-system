import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vfstr/constants/serverurl.dart';
import 'package:vfstr/screens/cred_login_screen.dart';
import 'package:vfstr/screens/EmployeeLocationsMapScreen.dart';

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
    String employeeId = _getEmployeeIdController.text.trim();  

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

void _showLocationOptionsDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Select Location Filter"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);  // Close dialog
                _showEmployeeIdInputDialog();
              },
              child: Text("By Employee ID"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showDatePicker();
              },
              child: Text("By Date"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeLocationMapScreen(filterType: 'all',),
                  ),
                );
              },
              child: Text("All Locations"),
            ),
          ],
        ),
      );
    },
  );
}

void _showEmployeeIdInputDialog() {
  final TextEditingController _employeeIdInputController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Enter Employee ID"),
        content: TextField(
          controller: _employeeIdInputController,
          decoration: InputDecoration(labelText: "Employee ID"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              String employeeId = _employeeIdInputController.text.trim();
              Navigator.pop(context);
              if (employeeId.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeLocationMapScreen(
                      filterType: 'byEmployeeId',
                      employeeId: employeeId,
                    ),
                  ),
                );
              } else {
                _showDialog("Error", "Please enter an Employee ID.");
              }
            },
            child: Text("View"),
          ),
        ],
      );
    },
  );
}

void _showDatePicker() async {
  DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2023),
    lastDate: DateTime.now(),
  );

  if (selectedDate != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeLocationMapScreen(
          filterType: 'byDate',
          selectedDate: selectedDate.toIso8601String(), // Send as String or DateTime
        ),
      ),
    );
  }
}


  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text("Admin Home"),
  //       actions: [
  //         IconButton(
  //           icon: Icon(Icons.logout, size: 24),
  //           onPressed: _logout,
  //         ),
  //       ],
  //     ),
  //     body: Padding(
  //       padding: EdgeInsets.all(20),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           SizedBox(height: 30),
  //           ElevatedButton(
  //             onPressed: _showAddEmployeeDialog,
  //             style: ElevatedButton.styleFrom(
  //               minimumSize: Size(200, 60), 
  //               padding: EdgeInsets.all(0),   
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10), 
  //               ),
  //             ),
  //             child: Text("Add Employee"),
  //           ),

  //           SizedBox(height: 20),

  //           ElevatedButton(
  //             onPressed: _showGetEmployeeDialog,
  //             style: ElevatedButton.styleFrom(
  //               minimumSize: Size(200, 60), 
  //               padding: EdgeInsets.all(0),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //             ),
  //             child: Text("Get Employee Details"),
  //           ),
  //           SizedBox(height: 20),
  //           ElevatedButton(
  //             onPressed: _showLocationOptionsDialog,
  //             style: ElevatedButton.styleFrom(
  //               minimumSize: Size(200, 60),
  //               padding: EdgeInsets.all(0),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //             ),
  //             child: Text("View Employee Locations"),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Home"),
        backgroundColor: Color.fromRGBO(81, 97, 91, 1), // Your theme color
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 24, color: Color.fromRGBO(245, 241, 230, 1)),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 buttons per row
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.2, // Adjust button shape
          ),
          itemCount: 3, // 4 buttons including Profile
          itemBuilder: (context, index) {
            List<Map<String, dynamic>> options = [
              {
                "title": "Add Employee",
                "icon": Icons.person_add,
                "action": _showAddEmployeeDialog,
              },
              {
                "title": "View Employee Locations",
                "icon": Icons.location_on,
                "action": _showLocationOptionsDialog,
              },
              {
                "title": "Get Employee Details",
                "icon": Icons.details,
                "action": _showGetEmployeeDialog,
              },
            ];

            return GestureDetector(
              onTap: options[index]["action"],
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(81, 97, 91, 1), // Your button background color
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(options[index]["icon"], color: Color.fromRGBO(245, 241, 230, 1), size: 40),
                    SizedBox(height: 10),
                    Text(
                      options[index]["title"],
                      style: TextStyle(
                        color: Color.fromRGBO(245, 241, 230, 1), 
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}
