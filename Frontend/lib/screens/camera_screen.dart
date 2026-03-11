import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../app_routes.dart';
import '../main.dart';

class CameraScreen extends StatefulWidget {
  final String category;
  final String healthIssues;

  const CameraScreen({
    super.key,
    required this.category,
    required this.healthIssues,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras![0],
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _takePicture() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final XFile image = await _cameraController!.takePicture();
      await _analyzeImage(File(image.path));
    } catch (e) {
      debugPrint("Camera error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _isProcessing = true);
      await _analyzeImage(File(picked.path));
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    print(
        '[CameraScreen] Sending image: ${imageFile.path}, category: ${widget.category}, healthIssues: ${widget.healthIssues}');

    try {
      final result = await ApiService.analyzeImage(
        imageFile.path,
        widget.category,
        widget.healthIssues,
      );

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.results,
        arguments: {
          'category': widget.category,
          'imageUri': imageFile.path,
          'results': result,
        },
      );
    } catch (e) {
      debugPrint("Error analyzing image: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to analyze image')),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Scan ${widget.category}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: MyApp.sageGreen,
        centerTitle: true,
      ),
      body: _isCameraInitialized
          ? Stack(
              children: [
                Positioned.fill(child: CameraPreview(_cameraController!)),

                // Processing overlay
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 12),
                          Text(
                            "Analyzing...",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom controls
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCircleButton(
                        icon: Icons.photo_library,
                        onTap: _isProcessing ? null : _pickFromGallery,
                        label: "Gallery",
                      ),
                      _buildCircleButton(
                        icon: Icons.camera_alt,
                        size: 60,
                        onTap: _isProcessing ? null : _takePicture,
                        label: "Capture",
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(color: MyApp.sageGreen),
            ),
    );
  }

  /// Reusable circular button with label
  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback? onTap,
    String? label,
    double size = 50,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(size),
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: onTap == null ? Colors.grey : MyApp.sageGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.6),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ]
      ],
    );
  }
}
