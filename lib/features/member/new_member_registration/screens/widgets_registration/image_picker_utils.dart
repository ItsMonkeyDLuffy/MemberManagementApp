import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '/core/constants/colors.dart';

// ✅ IMPORT YOUR NEW CUSTOM CAMERA SCREEN
// (Ensure this path matches where you saved custom_camera_screen.dart)
import '../../../../shared/screens/custom_camera_screen.dart';

class ImagePickerUtils {
  static final ImagePicker _picker = ImagePicker();

  static void showSourceSelection(
    BuildContext context, {
    required Function(File) onImagePicked,
  }) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              // 📸 OPTION 1: CUSTOM IN-APP CAMERA (Fixes Crash)
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text("Take Photo"),
                onTap: () async {
                  Navigator.pop(ctx); // Close sheet

                  // ✅ 1. Check Camera Permission First
                  final status = await Permission.camera.request();
                  if (status.isPermanentlyDenied) {
                    _showSettingsDialog(context);
                    return;
                  }

                  if (status.isGranted) {
                    // ✅ 2. Open Custom Camera Screen
                    if (!context.mounted) return;

                    final File? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomCameraScreen(),
                      ),
                    );

                    // ✅ 3. Handle Result
                    if (result != null) {
                      onImagePicked(result);
                    }
                  }
                },
              ),

              // 🖼️ OPTION 2: GALLERY (Uses Standard Picker)
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                ),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickGallery(context, onImagePicked);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // 🖼️ GALLERY LOGIC (Standard Image Picker is fine here)
  // ---------------------------------------------------------
  static Future<void> _pickGallery(
    BuildContext context,
    Function(File) onPicked,
  ) async {
    // 1. Permission Check
    bool hasPermission = await _handleGalleryPermissions(context);
    if (!hasPermission) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
        requestFullMetadata: false,
      );

      if (!context.mounted) return;

      if (image != null) {
        onPicked(File(image.path));
      }
    } catch (e) {
      debugPrint("❌ Gallery Error: $e");
    }
  }

  // 🛡️ PERMISSION HELPERS
  static Future<bool> _handleGalleryPermissions(BuildContext context) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      // Android 13+ (SDK 33)
      if (androidInfo.version.sdkInt >= 33) {
        final photos = await Permission.photos.request();
        return photos.isGranted;
      }
      // Android 12 and below
      else {
        final storage = await Permission.storage.request();
        return storage.isGranted;
      }
    } else {
      // iOS
      final photos = await Permission.photos.request();
      return photos.isGranted;
    }
  }

  static void _showSettingsDialog(BuildContext context) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text("Camera access is needed to take photos."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text("Settings"),
          ),
        ],
      ),
    );
  }
}
