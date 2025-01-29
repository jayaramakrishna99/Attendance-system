import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraWidget extends StatefulWidget {
  final Function(File) onImageCaptured;

  const CameraWidget({required this.onImageCaptured});

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;

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
    await _cameraController.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  // Capture image
  Future<void> _captureImage() async {
    if (!_cameraController.value.isInitialized) return;

    final image = await _cameraController.takePicture();
    File capturedImage = File(image.path);
    widget.onImageCaptured(capturedImage);  // Return captured image to LoginScreen
    Navigator.pop(context);  // Close CameraWidget
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Capture Image')),
      body: Column(
        children: [
          _isCameraInitialized
              ? CameraPreview(_cameraController) // Camera preview
              : Center(child: CircularProgressIndicator()),
          ElevatedButton(
            onPressed: _captureImage,
            child: Text('Capture Image'),
          ),
        ],
      ),
    );
  }
}
