import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vfstr/screens/home_screen.dart';
import 'package:vfstr/screens/user_add_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vfstr/constants/serverurl.dart';
import 'package:vfstr/services/location_service.dart';
import 'package:lottie/lottie.dart';

class CredLoginScreen extends StatefulWidget {
  @override
  _CredLoginScreenState createState() => _CredLoginScreenState();
}

class _CredLoginScreenState extends State<CredLoginScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adminIdController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();

  bool _isLoadingLogin = false; 
  bool _isLoadingAdmin = false; 

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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

Future<void> _login() async {
  String employeeId = _employeeIdController.text.trim();
  String password = _passwordController.text.trim();

  if (employeeId.isEmpty || password.isEmpty) {
    _showDialog("Error", "Please enter Employee ID and Password.");
    return;
  }

  setState(() {
    _isLoadingLogin = true; // Full screen loader ON
  });

  try {
    // Check if location services are enabled
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      _showDialog("Location Required", "Please enable location services and try again.");
      setState(() {
        _isLoadingLogin = false;
      });
      return;
    }

    // Request permission if not already granted
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showDialog("Permission Required", "Location permission is required to login.");
        setState(() {
          _isLoadingLogin = false;
        });
        return;
      }
    }

    // Proceed with login API call
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
      // After successful login, get location
      final position = await LocationService.getCurrentLocation();

      if (position == null) {
        _showDialog("Location Error", "Unable to retrieve your location.");
        setState(() {
          _isLoadingLogin = false;
        });
        return;
      }

      // Send location to backend
      await _sendLocationToBackend(employeeId, position.latitude, position.longitude);

      setState(() {
        _isLoadingLogin = false;
      });

      // Navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      var responseBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      String errorMessage = responseBody.containsKey('detail')
          ? responseBody['detail']
          : "Login failed";
      _showDialog("Login Failed", errorMessage);
      setState(() {
        _isLoadingLogin = false;
      });
    }
  } catch (e) {
    _showDialog("Error", "An error occurred: $e");
    setState(() {
      _isLoadingLogin = false;
    });
  }
}

Future<void> _sendLocationToBackend(String employeeId, double latitude, double longitude) async {
  try {
    var uri = Uri.parse("$serverurl/api/location/");
    var response = await http.post(
      uri,
      body: jsonEncode({
        'employee_id': employeeId,
        'latitude': latitude,
        'longitude': longitude,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } 
  catch (e) {
    }
}

  void _showAdminLoginDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                _isLoadingAdmin
                    ? Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          String adminId = _adminIdController.text.trim();
                          String password = _adminPasswordController.text.trim();

                          if (adminId.isEmpty || password.isEmpty) {
                            _showDialog("Error", "Please enter Admin ID and Password.");
                            return;
                          }

                          setState(() {
                            _isLoadingAdmin = true;
                          });

                          // Simulating an API call for admin login (Replace this with actual API call)
                          await Future.delayed(Duration(seconds: 2));

                          setState(() {
                            _isLoadingAdmin = false;
                          });

                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => UserAddScreen()),
                          );
                        },
                        child: Text("Login"),
                      ),
              ],
            );
          },
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
                  onPressed: _isLoadingLogin ? null : _login,
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
            onPressed: _isLoadingLogin ? null : _showAdminLoginDialog,
            child: Text("Admin Login"),
          ),
        ),

      

      if (_isLoadingLogin)
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/animations/loading.json',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 1),
                    Text(
                      "Logging in...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}