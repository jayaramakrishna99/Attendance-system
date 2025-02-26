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
  bool _isLoading = false; // Loading state

  // Get the file path to save the captured image
  Future<String> getFilePath() async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/captured_image.jpg';
  }

  // Show response in a dialog box
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Mark attendance with loading state
  void _markAttendance() async {
    if (_facultyIdController.text.isNotEmpty && isImageCaptured) {
      setState(() {
        _isLoading = true; // Show loading
      });

      final uri = Uri.parse("$serverurl/api/attendance/");
      var request = http.MultipartRequest("POST", uri);

      request.fields['faculty_id'] = _facultyIdController.text;

      String filePath = await getFilePath();
      File imageFile = File(filePath);
      await imageFile.writeAsBytes(await _capturedImage.readAsBytes());

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _capturedImage.path,
        filename: 'captured_image.jpg',
      ));

      try {
        final response = await request.send();
        final responseData = await response.stream.bytesToString();

        setState(() {
          _isLoading = false; // Hide loading
        });

        if (response.statusCode == 200) {
          _showDialog("Success", jsonDecode(responseData)['message']);
        } else {
          _showDialog("Failed", "Error: ${jsonDecode(responseData)['detail']}");
        }
      } catch (e) {
        setState(() {
          _isLoading = false; // Hide loading
        });

        _showDialog("Error", "An error occurred: $e");
      }
    } else {
      _showDialog("Warning", "Please enter Faculty ID and capture an image.");
    }
  }

  // Called when the image is captured
  void _onImageCaptured(File capturedImage) {
    setState(() {
      _capturedImage = capturedImage;
      isImageCaptured = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 241, 230, 1),
      appBar: AppBar(
        title: Text("Mark Attendance"),
        backgroundColor: Color.fromRGBO(81, 97, 91, 1),
      ),
      body: SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Align center
      children: [
        TextField(
          controller: _facultyIdController,
          decoration: InputDecoration(
            labelText: 'Faculty ID',
            labelStyle: TextStyle(color: Color.fromRGBO(81, 97, 91, 1)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(81, 97, 91, 1)),
            ),
          ),
        ),
        SizedBox(height: 20),

        isImageCaptured
            ? Image.file(_capturedImage, height: 300)
            : Text("No image captured yet.", style: TextStyle(color: Color.fromRGBO(81, 97, 91, 1))),

        SizedBox(height: 20),

        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraWidgetLogin(
                  onImageCaptured: (capturedImage) {
                    setState(() {
                      _capturedImage = capturedImage;
                      isImageCaptured = true;
                    });
                  },
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(245, 241, 230, 1),
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
          ),
          child: Icon(Icons.camera_alt, size: 40, color: Color.fromRGBO(81, 97, 91, 1)),
        ),
        SizedBox(height: 30),

        _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _markAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(81, 97, 91, 1),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(
                  'Mark Attendance',
                  style: TextStyle(fontSize: 18, color: Color.fromRGBO(245, 241, 230, 1)),
                ),
              ),
      ],
    ),
  ),
),

    );
  }
}
