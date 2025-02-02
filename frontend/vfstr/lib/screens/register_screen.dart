import 'package:flutter/material.dart';
import 'package:vfstr/constants/serverurl.dart';
import 'package:vfstr/widgets/camera_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _facultyIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _capturedImage;

  // Function to open the Camera Widget
  void _openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraWidget(
          onImageCaptured: (imagePath) {
            setState(() {
              _capturedImage = imagePath;
            });
          },
        ),
      ),
    );
  }

  // Function to register the faculty and send data to the backend
  Future<void> _register() async {
    if (_facultyIdController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and capture an image!')),
      );
      return;
    }

    try {
      var uri = Uri.parse("$serverurl/api/register/");
      var request = http.MultipartRequest('POST', uri);

      // Add form fields
      request.fields['id'] = _facultyIdController.text;
      request.fields['name'] = _nameController.text;

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath('image', _capturedImage!),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Faculty registered successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register faculty!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Function to update the image for the existing faculty
  // Future<void> _updateImage() async {
  //   if (_facultyIdController.text.isEmpty || _capturedImage == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please provide the faculty ID and capture a new image!')),
  //     );
  //     return;
  //   }

  //   try {
  //     var uri = Uri.parse("$serverurl/api/update-image/");
  //     var request = http.MultipartRequest('POST', uri);

  //     // Add faculty ID for updating image
  //     request.fields['id'] = _facultyIdController.text;

  //     // Add the new image file
  //     request.files.add(
  //       await http.MultipartFile.fromPath('image', _capturedImage!),
  //     );

  //     var response = await request.send();
  //     if (response.statusCode == 200) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Image updated successfully!')),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to update image!')),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $e')),
  //     );
  //   }
  // }
  Future<void> _updateImage() async {
  if (_facultyIdController.text.isEmpty || _capturedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please provide the faculty ID and capture a new image!')),
    );
    return;
  }

  try {
    var uri = Uri.parse("$serverurl/api/update-image/");
    var request = http.MultipartRequest('POST', uri);

    // Add faculty ID for updating image
    request.fields['faculty_id'] = _facultyIdController.text;  // Updated field name

    // Add the new image file
    request.files.add(
      await http.MultipartFile.fromPath('image', _capturedImage!),  // Ensure captured image is a path to file
    );

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();  // To get detailed response body
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update image! ${responseBody}')),  // Include response body for debugging
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 241, 230, 1), // Background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Faculty ID TextField
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

            // Name TextField
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Color.fromRGBO(81, 97, 91, 1)),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(81, 97, 91, 1)),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Camera button and status text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.camera_alt, size: 40, color: Color.fromRGBO(81, 97, 91, 1)),
                  onPressed: _openCamera,
                ),
                SizedBox(width: 10),
                Text(
                  _capturedImage == null ? 'No image captured' : 'Image captured!',
                  style: TextStyle(
                    color: _capturedImage == null ? Colors.grey : Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Display captured image if available
            if (_capturedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Image.file(
                  File(_capturedImage!), // Display captured image
                  width: 150,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

            // Register button
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(81, 97, 91, 1), // Button color
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                'Register',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(245, 241, 230, 1), // Text color in the button
                ),
              ),
            ),

            // Update button
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(81, 97, 91, 1), // Button color
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                'Update Image',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(245, 241, 230, 1), // Text color in the button
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
