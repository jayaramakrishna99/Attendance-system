import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vfstr/constants/serverurl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:vfstr/screens/cred_login_screen.dart';
import 'package:vfstr/widgets/camera_widget_login.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _facultyIdController = TextEditingController();
  late File _capturedImage;
  bool isImageCaptured = false;
  bool _isLoading = false; 

  Future<String> getFilePath() async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/captured_image.jpg';
  }


  void _showDialog(String title, String message, {VoidCallback? onOk}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
              if (onOk != null) {
                onOk(); 
              }
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}


void _markAttendance() async {
  if (_facultyIdController.text.isNotEmpty && isImageCaptured) {
    setState(() {
      _isLoading = true;
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
    _isLoading = false;
  });

  if (response.statusCode == 200) {
    _showDialog("Success", jsonDecode(responseData)['message']);
  } else {
    final decodedResponse = jsonDecode(responseData);
    String errorMessage = decodedResponse['detail'] ?? "Attendance failed";

    switch (response.statusCode) {
      case 404:
        _showDialog("Faculty Not Found", errorMessage);
        break;

      case 400:
        _showDialog("Image Not Found", errorMessage);
        break;

      case 401:
        _showDialog("Location Error", "Location not found. Please login again.", onOk: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CredLoginScreen()),
          );
        });
        break;

      case 440:
        _showDialog("Session Expired", "Your session has expired. Please login again.", onOk: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CredLoginScreen()),
          );
        });
        break;

      default:
        _showDialog("Failed", "Error: $errorMessage");
    }
  }
} catch (e) {
  setState(() {
    _isLoading = false;
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
            labelText: 'Employee ID',
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
