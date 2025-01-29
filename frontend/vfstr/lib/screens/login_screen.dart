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
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _facultyIdController,
              decoration: InputDecoration(labelText: 'Faculty ID'),
            ),
            SizedBox(height: 20),
            isImageCaptured
                ? Image.file(
                    _capturedImage,
                    height: 300,
                  )  // Display captured image
                : Text("No image captured yet."),  // Message when no image is captured
            
            SizedBox(height: 20),
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
                backgroundColor: Colors.blue, // Customize the color of the button if needed
                shape: CircleBorder(), // Make the button round
                padding: EdgeInsets.all(20), // Adjust padding for the icon size
              ),
              child: Icon(
                Icons.camera_alt, // Camera icon
                size: 40, // Icon size
                color: Colors.white, // Icon color
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _markAttendance,
              child: Text('Login', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
