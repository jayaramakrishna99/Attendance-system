import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class CameraWidget extends StatefulWidget {
  final Function(String) onImageCaptured;

  const CameraWidget({required this.onImageCaptured});

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _initializeCamera();
  }

  // Initialize the camera
  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.last; // Select the first available camera

    _cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _cameraController.initialize();
    setState(() {});
  }

  // Capture the image
  void _captureImage() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      widget.onImageCaptured(image.path);
      Navigator.pop(context);
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    // Unlock orientation when exiting
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Capture Image')),
      body: Column(
        children: [
          // Set Camera Preview with height and width
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // Use a Container to set the desired width and height for the preview
                  return Container(
                    width: double.infinity,  // Full screen width
                    height: 400,  // Set height for preview
                    child: CameraPreview(_cameraController),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.camera, size: 50, color: Colors.blue),
            onPressed: _captureImage,
          ),
        ],
      ),
    );
  }
}
