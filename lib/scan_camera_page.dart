import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'image_preview_page.dart';
import 'services/onnx_model_service.dart';

class ScanCameraPage extends StatefulWidget {
  const ScanCameraPage({super.key});

  @override
  State<ScanCameraPage> createState() => _ScanCameraPageState();
}

class _ScanCameraPageState extends State<ScanCameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndInit();
    
    // Preload the TensorFlow model
    _preloadModel();
  }

  Future<void> _requestPermissionsAndInit() async {
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.storage.request(); // Android <= 12
    final mediaStatus = await Permission.photos.request(); // Android 13+

    if (cameraStatus.isGranted &&
        (storageStatus.isGranted || mediaStatus.isGranted)) {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        _initializeControllerFuture = _controller!.initialize();
        setState(() {});
      } else {
        _showError("Aucune caméra disponible sur cet appareil.");
      }
    } else {
      _showError("Permissions caméra ou stockage refusées.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }
  
  // Preload the ONNX model in background
  Future<void> _preloadModel() async {
    try {
      await OnnxModelService.loadModel();
      debugPrint('ONNX model preloaded successfully');
    } catch (e) {
      debugPrint('Error preloading ONNX model: $e');
      // Don't show error to user as this is a background operation
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewPage(imagePath: image.path),
        ),
      );
    } catch (e) {
      _showError("Erreur de capture : $e");
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewPage(imagePath: picked.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_controller == null || _initializeControllerFuture == null)
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      CameraPreview(_controller!),
                      Positioned(
                        bottom: 30,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: _pickFromGallery,
                              icon: const Icon(Icons.photo,
                                  size: 40, color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: _takePicture,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.black, size: 35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erreur lors de l'initialisation de la caméra : ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}
