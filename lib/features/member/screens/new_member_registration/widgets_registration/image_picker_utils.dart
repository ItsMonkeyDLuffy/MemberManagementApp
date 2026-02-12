import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '/core/constants/colors.dart';

class ImagePickerUtils {
  static final ImagePicker _picker = ImagePicker();

  // Show the bottom sheet to choose Camera or Gallery
  static void showSourceSelection(
    BuildContext context, {
    required Function(File) onImagePicked,
  }) {
    // Park focus
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
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text("Take Photo"),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Future.delayed(const Duration(milliseconds: 300));
                  _pickImage(context, ImageSource.camera, onImagePicked);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                ),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Future.delayed(const Duration(milliseconds: 300));
                  _pickImage(context, ImageSource.gallery, onImagePicked);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Internal Logic: Permission + Resize + Compress
  static Future<void> _pickImage(
    BuildContext context,
    ImageSource source,
    Function(File) onPicked,
  ) async {
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      if (Platform.isAndroid) {
        status = await Permission.photos.request();
        if (status.isDenied) status = await Permission.storage.request();
      } else {
        status = await Permission.photos.request();
      }
    }

    if (status.isGranted) {
      try {
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 70, // Optimized for Upload
        );
        if (image != null) {
          onPicked(File(image.path));
        }
      } catch (e) {
        debugPrint("Error picking image: $e");
      }
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission disabled. Open Settings?")),
      );
    }
  }
}
