import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math'; 

class CameraWidget extends StatefulWidget {
  final Function(dynamic) onImageCaptured;

  const CameraWidget({required this.onImageCaptured, Key? key}) : super(key: key);

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
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


  Future<void> _captureImage() async {
  if (!_cameraController.value.isInitialized) return;

  try {
    final image = await _cameraController.takePicture();
    if (mounted) {
      widget.onImageCaptured(image.path); 
      Navigator.pop(context); 
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
        backgroundColor: const Color.fromRGBO(81, 97, 91, 1),
      ),
      backgroundColor: const Color.fromRGBO(245, 241, 230, 1),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error initializing camera: ${snapshot.error}'),
            );
          }

          return Stack(
            children: [
              Positioned(
                bottom: 400,
                left: 0, 
                child: SizedBox(
                  width: 400, 
                  height: 250, 
                  child: AspectRatio(
                    aspectRatio: _cameraController.value.aspectRatio,
                    child: Transform.rotate(
                      angle: -90 * pi / 180,
                      child: CameraPreview(_cameraController),
                    ),
                  ),
                ),
              ),

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