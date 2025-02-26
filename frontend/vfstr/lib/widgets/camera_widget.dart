import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math'; // For rotation

class CameraWidget extends StatefulWidget {
  final Function(dynamic) onImageCaptured;

  const CameraWidget({required this.onImageCaptured, Key? key}) : super(key: key);

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture; // To track the initialization status

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize camera
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);

    _cameraController = CameraController(frontCamera, ResolutionPreset.high);
    _initializeControllerFuture = _cameraController.initialize();
    setState(() {}); // Ensure the UI is updated after initialization
  }


  Future<void> _captureImage() async {
  if (!_cameraController.value.isInitialized) return;

  try {
    final image = await _cameraController.takePicture();
    if (mounted) {
      widget.onImageCaptured(image.path); // Send image path back
      Navigator.pop(context); // Close camera screen **after** sending the image
    }
  } catch (e) {
    print("Error capturing image: $e");
  }
}

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Image'),
        backgroundColor: const Color.fromRGBO(81, 97, 91, 1), // Dark Green
      ),
      backgroundColor: const Color.fromRGBO(245, 241, 230, 1), // Cream Background
      body: FutureBuilder<void>(
        future: _initializeControllerFuture, // Wait for the camera initialization
        builder: (context, snapshot) {
          // If the camera is still initializing, show a loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If there was an error initializing the camera, show an error message
          if (snapshot.hasError) {
            return Center(
              child: Text('Error initializing camera: ${snapshot.error}'),
            );
          }

          // Otherwise, show the camera preview and the capture button
          return Stack(
            children: [
              Positioned(
                bottom: 400, // Adjust vertical position
                left: 0, // Adjust horizontal position
                child: SizedBox(
                  width: 400, // Set width of the preview
                  height: 250, // Set height of the preview
                  child: AspectRatio(
                    aspectRatio: _cameraController.value.aspectRatio,
                    child: Transform.rotate(
                      angle: -90 * pi / 180, // Rotate preview by 90 degrees
                      child: CameraPreview(_cameraController),
                    ),
                  ),
                ),
              ),

              // Capture Icon Button at the bottom center
              Positioned(
                bottom: 150,
                left: 0,
                right: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.camera, size: 70, color: Color.fromRGBO(81, 97, 91, 1)), // Dark Green Icon
                    onPressed: _captureImage,
                    splashRadius: 40,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}