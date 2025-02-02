import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class CameraWidget extends StatefulWidget {
  final Function(String) onImageCaptured;

  const CameraWidget({required this.onImageCaptured, Key? key}) : super(key: key);

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait mode
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initializeCamera();
  }

  // Initialize the camera
  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.last; // Use the front or back camera

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _cameraController.initialize().then((_) {
      setState(() {
        _isCameraInitialized = true;
      });
    }).catchError((e) {
      print("Error initializing camera: $e");
    });
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
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft],
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: _isCameraInitialized
          ? Stack(
              children: [
                // Camera preview with rotation
                Positioned(
                  bottom: 400, // Adjust vertical position
                  left: 0, // Adjust horizontal position
                  child: SizedBox(
                    width: 400, // Set preview width
                    height: 250, // Set preview height
                    child: AspectRatio(
                      aspectRatio: _cameraController.value.aspectRatio,
                      child: Transform.rotate(
                        angle: -90 * pi / 180, // Rotate preview by 90 degrees
                        child: CameraPreview(_cameraController),
                      ),
                    ),
                  ),
                ),

                // Capture button
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 175, bottom: 175), // Add margin
                    child: IconButton(
                      icon: const Icon(Icons.camera, size: 70, color: Color.fromRGBO(81, 97, 91, 1)),
                      onPressed: _captureImage,
                    ),
                  ),
                ),

              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
