import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vfstr/constants/serverurl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:vfstr/widgets/camera_widget_login.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _facultyIdController = TextEditingController();
  late File _capturedImage;
  bool isImageCaptured = false;

  // Get the file path to save the captured image
  Future<String> getFilePath() async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/captured_image.jpg'; // Path where the image will be saved
  }

  // Mark attendance by sending data to backend
  void _markAttendance() async {
    if (_facultyIdController.text.isNotEmpty && _capturedImage != null) {
      final uri = Uri.parse("$serverurl/api/attendance/");

      var request = http.MultipartRequest("POST", uri);

      // Add faculty_id to the request as form-data
      request.fields['faculty_id'] = _facultyIdController.text; // Faculty ID from text field

      // Save the captured image to a proper path
      String filePath = await getFilePath();
      File imageFile = File(filePath);
      await imageFile.writeAsBytes(await _capturedImage.readAsBytes());

      // Add the captured image file
      request.files.add(await http.MultipartFile.fromPath(
        'image',  // The key on the backend
        _capturedImage.path,
        filename: 'captured_image.jpg',
      ));

      try {
        final response = await request.send();

        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          print("Response from server: $responseData");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonDecode(responseData)['message'])),
          );
        } else {
          final errorData = await response.stream.bytesToString();
          print("Error response from server: $errorData");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to mark attendance: $errorData")),
          );
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter Faculty ID and capture an image.")),
      );
    }
  }

  // This will be called from CameraWidget when the image is captured
  void _onImageCaptured(File capturedImage) {
    setState(() {
      _capturedImage = capturedImage;
      isImageCaptured = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 241, 230, 1), // Background color
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Color.fromRGBO(245, 241, 230, 1), // Match app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Faculty ID input field
            TextField(
              controller: _facultyIdController,
              decoration: InputDecoration(
                labelText: 'Faculty ID',
                labelStyle: TextStyle(color: Color.fromRGBO(81, 97, 91, 1)), // Label color
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(81, 97, 91, 1)), // Focused border color
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Captured image display
            isImageCaptured
                ? Image.file(
                    _capturedImage,
                    height: 300,
                  )  // Display captured image
                : Text(
                    "No image captured yet.",
                    style: TextStyle(color: Color.fromRGBO(81, 97, 91, 1)), // Text color
                  ),
            
            SizedBox(height: 20),
            
            // Camera button with custom theme
            ElevatedButton(
              onPressed: () {
                // Navigate to Camera Widget for capturing the image
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraWidget(
                      onImageCaptured: _onImageCaptured,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(245, 241, 230, 1), // Background color for the button
                shape: CircleBorder(),
                padding: EdgeInsets.all(20),
              ),
              child: Icon(
                Icons.camera_alt,
                size: 40,
                color: Color.fromRGBO(81, 97, 91, 1), // Icon color
              ),
            ),
            SizedBox(height: 30),
            
            // Login button with custom theme
            ElevatedButton(
              onPressed: _markAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(81, 97, 91, 1), // Button color
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(245, 241, 230, 1), // Text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
