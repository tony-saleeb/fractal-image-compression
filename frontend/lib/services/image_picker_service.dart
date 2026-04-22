import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from the gallery (returns XFile for web)
  Future<XFile?> pickFromGalleryXFile() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      return image;
    } catch (e) {
      debugPrint('ImagePickerService: Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick an image from the gallery
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null) {
        if (kIsWeb) {
          // On web, we can't create real files, so we'll return null
          // and handle the XFile directly in the UI
          debugPrint(
            'ImagePickerService: Web platform - returning null File, use bytes instead',
          );
          return null;
        } else {
          return File(image.path);
        }
      }
      return null;
    } catch (e) {
      debugPrint('ImagePickerService: Error picking image from gallery: $e');
      return null;
    }
  }

  /// Capture an image from the camera (returns XFile for web)
  Future<XFile?> captureFromCameraXFile() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      return image;
    } catch (e) {
      debugPrint('ImagePickerService: Error capturing from camera: $e');
      return null;
    }
  }

  /// Capture an image from the camera
  Future<File?> captureFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (image != null) {
        if (kIsWeb) {
          // On web, we can't create real files, so we'll return null
          // and handle the XFile directly in the UI
          debugPrint(
            'ImagePickerService: Web platform - returning null File, use bytes instead',
          );
          return null;
        } else {
          return File(image.path);
        }
      }
      return null;
    } catch (e) {
      debugPrint('ImagePickerService: Error capturing from camera: $e');
      return null;
    }
  }

  /// Show a dialog to choose between camera and gallery
  static Future<File?> showImageSourceDialog(BuildContext context) async {
    final ImagePickerService service = ImagePickerService();

    return showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Image Source',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () async {
                    final file = await service.pickFromGallery();
                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () async {
                    final file = await service.captureFromCamera();
                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
