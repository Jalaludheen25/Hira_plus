import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static const String _logTag = '[PermissionHelper]';

  /// Handles image selection from photo library with proper permission handling for different platforms
  static Future<File?> pickImageWithPermission(BuildContext context) async {
    debugPrint('$_logTag 📸 Starting photo library selection process');

    try {
      final picker = ImagePicker();

      if (Platform.isIOS) {
        // For iOS, use PHPicker which doesn't require explicit photo library permissions
        debugPrint('$_logTag 🍎 iOS: Using PHPicker for photo library access');

        // Attempt to pick image directly from gallery
        debugPrint('$_logTag 📤 Opening photo library...');
        final pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85, // Compress image to reasonable quality
          maxWidth: 1920, // Limit max width
          maxHeight: 1920, // Limit max height
        );

        if (pickedFile != null) {
          debugPrint(
              '$_logTag ✅ Image selected successfully: ${pickedFile.path}');
          final file = File(pickedFile.path);

          // Verify file exists and is readable
          if (await file.exists()) {
            final fileSize = await file.length();
            debugPrint('$_logTag 📊 File size: $fileSize bytes');
            return file;
          } else {
            debugPrint(
                '$_logTag ❌ Selected file does not exist: ${pickedFile.path}');
            return null;
          }
        } else {
          debugPrint('$_logTag ❌ No image was selected from photo library');
          return null;
        }
      } else {
        // For Android, handle storage permissions for photo library access
        debugPrint('$_logTag 🤖 Android: Handling photo library permissions');

        // For Android 13+ (API 33+), use granular media permissions
        final requiredPermission = Permission.photos;
        const permissionName = 'Photo Library';

        final status = await requiredPermission.status;
        debugPrint('$_logTag 🔐 $permissionName permission status: $status');

        if (status.isPermanentlyDenied) {
          debugPrint(
              '$_logTag 🚫 $permissionName permission permanently denied');
          await _showPermissionDeniedDialog(context, permissionName);
          return null;
        } else if (status.isDenied) {
          final requestResult = await requiredPermission.request();
          debugPrint(
              '$_logTag 🔄 $permissionName permission request result: $requestResult');

          if (!requestResult.isGranted) {
            debugPrint('$_logTag ❌ $permissionName permission denied');
            if (requestResult.isPermanentlyDenied) {
              await _showPermissionDeniedDialog(context, permissionName);
            }
            return null;
          }
        }

        final pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1920,
        );

        if (pickedFile != null) {
          debugPrint('$_logTag ✅ Image selected: ${pickedFile.path}');
          return File(pickedFile.path);
        }
      }

      debugPrint('$_logTag ❌ No image selected');
      return null;
    } catch (e, stackTrace) {
      debugPrint('$_logTag 💥 Error during photo library selection: $e');
      debugPrint('$_logTag 📚 Stack trace: $stackTrace');
      return null;
    }
  }

  /// Shows a dialog when permission is permanently denied
  static Future<void> _showPermissionDeniedDialog(
      BuildContext context, String permissionName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Force user to make a choice
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$permissionName Access Required'),
          content: Text(
            'To select images for banner uploads, please enable $permissionName access in your device settings.\n\nGo to Settings > Privacy & Security > $permissionName > Hira Plus and enable access.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}
