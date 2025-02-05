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
  bool _isLoadingRegister = false;
  bool _isLoadingUpdate = false;

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

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CameraWidget(
    //       onImageCaptured: (imagePath) {
    //         setState(() {
    //           _capturedImage = imagePath;
    //         });
    //       },
    //     ),
    //   ),
    // );
  }

  Future<void> _register() async {
    if (_facultyIdController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _capturedImage == null) {
      _showDialog("Error", "Please fill all fields and capture an image!");
      return;
    }

    setState(() => _isLoadingRegister = true);

    try {
      var uri = Uri.parse("$serverurl/api/register/");
      var request = http.MultipartRequest('POST', uri);
      request.fields['id'] = _facultyIdController.text;
      request.fields['name'] = _nameController.text;
      request.files.add(await http.MultipartFile.fromPath('image', _capturedImage!));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      setState(() => _isLoadingRegister = false);

      if (response.statusCode == 200) {
        _showDialog("Success", "Faculty registered successfully!");
      } else {
        _showDialog("Error", "Failed to register faculty!\n$responseData");
      }
    } catch (e) {
      setState(() => _isLoadingRegister = false);
      _showDialog("Error", "An error occurred: $e");
    }
  }

  Future<void> _updateImage() async {
    if (_facultyIdController.text.isEmpty || _capturedImage == null) {
      _showDialog("Error", "Please provide the Faculty ID and capture a new image!");
      return;
    }

    setState(() => _isLoadingUpdate = true);

    try {
      var uri = Uri.parse("$serverurl/api/update-image/");
      var request = http.MultipartRequest('POST', uri);
      request.fields['faculty_id'] = _facultyIdController.text;
      request.files.add(await http.MultipartFile.fromPath('image', _capturedImage!));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      setState(() => _isLoadingUpdate = false);

      if (response.statusCode == 200) {
        _showDialog("Success", "Image updated successfully!");
      } else {
        _showDialog("Error", "Failed to update image!\n$responseBody");
      }
    } catch (e) {
      setState(() => _isLoadingUpdate = false);
      _showDialog("Error", "An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 241, 230, 1),
      appBar: AppBar(
        title: Text("Registration"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                SizedBox(height: 20),

                if (_capturedImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Image.file(
                      File(_capturedImage!),
                      width: 150,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),

                SizedBox(height: 20),

                _isLoadingRegister
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(81, 97, 91, 1),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        child: Text(
                          'Register',
                          style: TextStyle(fontSize: 18, color: Color.fromRGBO(245, 241, 230, 1)),
                        ),
                      ),

                SizedBox(height: 20),

                _isLoadingUpdate
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _updateImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(81, 97, 91, 1),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        child: Text(
                          'Update Image',
                          style: TextStyle(fontSize: 18, color: Color.fromRGBO(245, 241, 230, 1)),
                        ),
                      ),

                SizedBox(height: 20), // Add extra spacing at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
