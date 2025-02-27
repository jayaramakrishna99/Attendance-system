import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math'; // For rotation

class CameraWidgetLogin extends StatefulWidget {
  final Function(dynamic) onImageCaptured;

  const CameraWidgetLogin({required this.onImageCaptured, Key? key}) : super(key: key);

  @override
  _CameraWidgetLoginState createState() => _CameraWidgetLoginState();
}

class _CameraWidgetLoginState extends State<CameraWidgetLogin> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture; 

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
    setState(() {}); 
  }

  // Capture image
  Future<void> _captureImage() async {
    if (!_cameraController.value.isInitialized) return;

    final image = await _cameraController.takePicture();
    dynamic capturedImage;
    if (widget.onImageCaptured is Function(File)) {
      capturedImage = File(image.path);
    } else if (widget.onImageCaptured is Function(String)) {
      capturedImage = image.path;
    }
    widget.onImageCaptured(capturedImage);
    Navigator.pop(context);
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
        backgroundColor: const Color.fromRGBO(81, 97, 91, 1), 
      ),
      backgroundColor: const Color.fromRGBO(245, 241, 230, 1), 
      body: FutureBuilder<void>(
        future: _initializeControllerFuture, 
        builder: (context, snapshot) {
          // If the camera is still initializing, show a loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

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
                    icon: const Icon(Icons.camera, size: 70, color: Color.fromRGBO(81, 97, 91, 1)), 
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