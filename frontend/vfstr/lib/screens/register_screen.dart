import 'package:flutter/material.dart';
import 'package:vfstr/constants/serverurl.dart';
import 'package:vfstr/widgets/camera_widget.dart';
import 'package:http/http.dart' as http;

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _facultyIdController,
            decoration: InputDecoration(
              labelText: 'Faculty ID',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.camera_alt, size: 40, color: Colors.blue),
                onPressed: _openCamera,
              ),
              SizedBox(width: 10),
              Text(
                _capturedImage == null
                    ? 'No image captured'
                    : 'Image captured!',
                style: TextStyle(
                  color: _capturedImage == null ? Colors.grey : Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: _register,
            child: Text('Register', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
