// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'dart:math'; // For rotation

// class CameraWidget extends StatefulWidget {
//   final Function(File) onImageCaptured;

//   const CameraWidget({required this.onImageCaptured, Key? key}) : super(key: key);

//   @override
//   _CameraWidgetState createState() => _CameraWidgetState();
// }

// class _CameraWidgetState extends State<CameraWidget> {
//   late CameraController _cameraController;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   // Initialize camera
//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final frontCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);

//     _cameraController = CameraController(frontCamera, ResolutionPreset.high);
//     await _cameraController.initialize();
//     setState(() {
//     });
//   }

//   // Capture image
//   Future<void> _captureImage() async {
//     if (!_cameraController.value.isInitialized) return;

//     final image = await _cameraController.takePicture();
//     File capturedImage = File(image.path);
//     widget.onImageCaptured(capturedImage);
//     Navigator.pop(context); // Close CameraWidget
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Capture Image'),
//         backgroundColor: const Color.fromRGBO(81, 97, 91, 1), // Dark Green
//       ),
//       backgroundColor: const Color.fromRGBO(245, 241, 230, 1), // Cream Background
//       body: Stack(
//         children: [
//           // Camera Preview with rotation
//           Positioned(
//             bottom: 400, // Adjust vertical position
//             left: 0, // Adjust horizontal position
//             child: SizedBox(
//               width: 400, // Set width of the preview
//               height: 250, // Set height of the preview
//               child: AspectRatio(
//                 aspectRatio: _cameraController.value.aspectRatio,
//                 child: Transform.rotate(
//                   angle: -90 * pi / 180, // Rotate preview by 90 degrees
//                   child: CameraPreview(_cameraController),
//                 ),
//               ),
//             ),
//           ),

//           // Capture Icon Button at the bottom center
//           Positioned(
//             bottom: 150,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: IconButton(
//                 icon: const Icon(Icons.camera, size: 70, color: Color.fromRGBO(81, 97, 91, 1)), // Dark Green Icon
//                 onPressed: _captureImage,
//                 splashRadius: 40,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
