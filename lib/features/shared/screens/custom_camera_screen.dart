import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class CustomCameraScreen extends StatefulWidget {
  const CustomCameraScreen({super.key});

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  bool _isCameraInitialized = false;
  XFile? _capturedImage;
  bool _isFlashOn = false;

  Offset? _focusPoint;
  bool _showFocusCircle = false;
  Timer? _focusTimer;

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.jpeg
            : ImageFormatGroup.bgra8888,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      await _controller!.setFlashMode(FlashMode.off);

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusTimer?.cancel();
    super.dispose();
  }

  // ✅ FIXED FOCUS LOGIC
  Future<void> _onTapToFocus(
    TapUpDetails details,
    BoxConstraints constraints,
    double previewHeight,
  ) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final double screenWidth = constraints.maxWidth;
    final double screenHeight = constraints.maxHeight;
    final double topOffset = (screenHeight - previewHeight) / 2;

    // Tap location relative to the top of the screen
    final double tapX = details.localPosition.dx;
    final double tapY = details.localPosition.dy;

    // Check if tap is within the camera preview boundaries
    if (tapY >= topOffset && tapY <= (topOffset + previewHeight)) {
      // Calculate normalized coordinates (0.0 to 1.0) for the camera sensor
      final double relativeY = (tapY - topOffset) / previewHeight;
      final double relativeX = tapX / screenWidth;

      try {
        // Set focus and exposure
        await _controller!.setFocusPoint(Offset(relativeX, relativeY));
        await _controller!.setExposurePoint(Offset(relativeX, relativeY));

        // ✅ Update the UI indicator position exactly where the finger touched
        setState(() {
          _focusPoint = Offset(tapX, tapY);
          _showFocusCircle = true;
        });

        _focusTimer?.cancel();
        _focusTimer = Timer(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _showFocusCircle = false);
        });
      } catch (e) {
        debugPrint("Focus Error: $e");
      }
    }
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      setState(() => _capturedImage = image);
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_capturedImage != null) return _buildPreviewScreen();

    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? LayoutBuilder(
              builder: (context, constraints) {
                final double previewWidth = constraints.maxWidth;
                final double previewHeight = previewWidth * (4 / 3);

                return Stack(
                  children: [
                    // A. Global Detector (covers the whole screen to catch coordinates)
                    GestureDetector(
                      onTapUp: (details) =>
                          _onTapToFocus(details, constraints, previewHeight),
                      child: Container(
                        color: Colors
                            .transparent, // Background stays black, but catches taps
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(
                          child: SizedBox(
                            width: previewWidth,
                            height: previewHeight,
                            child: CameraPreview(_controller!),
                          ),
                        ),
                      ),
                    ),

                    // B. Focus Indicator (Positioned based on screen coordinates)
                    if (_showFocusCircle && _focusPoint != null)
                      Positioned(
                        left: _focusPoint!.dx - 25,
                        top: _focusPoint!.dy - 25,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.greenAccent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),

                    // C. Top Bar (Close & Flash)
                    Positioned(
                      top: 50,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          IconButton(
                            icon: Icon(
                              _isFlashOn ? Icons.flash_on : Icons.flash_off,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: _toggleFlash,
                          ),
                        ],
                      ),
                    ),

                    // D. Capture Button
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _takePicture,
                          child: Container(
                            width: 75,
                            height: 75,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: Center(
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // E. Helper Text
                    Positioned(
                      bottom: 130,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          "Align Aadhar card within the frame",
                          style: GoogleFonts.roboto(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  // --- PREVIEW SCREEN ---
  Widget _buildPreviewScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const Spacer(),
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Image.file(File(_capturedImage!.path), fit: BoxFit.cover),
          ),
          const Spacer(),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => setState(() => _capturedImage = null),
                  child: Text(
                    "RETAKE",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, File(_capturedImage!.path)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "USE PHOTO",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    try {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    } catch (e) {
      debugPrint("Flash Error: $e");
    }
  }
}
