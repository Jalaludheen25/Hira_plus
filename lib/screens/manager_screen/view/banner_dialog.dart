import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/manager_screen/provider/banner_upload_provider.dart';

class BannerDialog extends StatelessWidget {
  const BannerDialog({Key? key}) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    print('[BannerDialog] 📸 Starting image picker process');

    // First check the current permission status
    var status = await Permission.photos.status;
    print('[BannerDialog] 🔐 Current photo permission status: $status');

    if (status.isDenied) {
      // If denied for the first time, request permission
      status = await Permission.photos.request();
      print('[BannerDialog] 🔐 Requested permission status: $status');
    }

    if (status.isGranted) {
      print('[BannerDialog] ✅ Permission granted, opening gallery');
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        final fileExtension = pickedFile.path.split('.').last.toLowerCase();

        print(
            '[BannerDialog] 📁 File selected: ${pickedFile.path}, Size: $fileSize bytes, Type: $fileExtension');

        Provider.of<BannerUploadProvider>(context, listen: false)
            .setImage(file);
        print('[BannerDialog] ✅ File set successfully');
      } else {
        print('[BannerDialog] ❌ No image selected by user');
      }
    } else if (status.isPermanentlyDenied) {
      print('[BannerDialog] 🚫 Permission permanently denied');

      // Show a dialog explaining why we need permission and how to enable it
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Photo Access Required'),
          content: const Text(
              'To upload banners, we need access to your photos. Please enable photo access in your device settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    } else {
      print('[BannerDialog] ❌ Permission denied: $status');
      toastification.show(
        context: context,
        title: const Text('Permission denied to access photos.'),
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        foregroundColor: ColorClass.white,
      );
    }
  }

  void _submit(BuildContext context) async {
    final provider = Provider.of<BannerUploadProvider>(context, listen: false);

    print('[BannerDialog] 🚀 Starting banner submission');
    print('[BannerDialog] 📋 Title: "${provider.title}"');
    print(
        '[BannerDialog] 🖼️ Image selected: ${provider.selectedImage != null}');

    if (provider.selectedImage != null) {
      final file = provider.selectedImage!;
      final fileSize = await file.length();
      print(
          '[BannerDialog] 📊 Image details: Path=${file.path}, Size=$fileSize bytes');
    }

    final error = await provider.submitBanner();

    if (error == null) {
      print('[BannerDialog] ✅ Banner created successfully!');
      Navigator.of(context).pop(true);
      toastification.show(
        context: context,
        title: const Text('Banner created successfully!'),
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 2),
        backgroundColor: ColorClass.brandDarkGreen,
        foregroundColor: ColorClass.white,
      );
    } else {
      print('[BannerDialog] ❌ Banner creation failed: $error');
      toastification.show(
        context: context,
        title: Text(error),
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        foregroundColor: ColorClass.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        print('[BannerDialog] 🏗️ Creating BannerUploadProvider');
        return BannerUploadProvider();
      },
      child: Consumer<BannerUploadProvider>(
        builder: (context, provider, _) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Create Banner',
                      style: TextStyleClass.poppinsSemiBold(fontSize: 20)),
                  const SizedBox(height: 16),

                  // Title input field
                  TextField(
                    onChanged: (value) {
                      print('[BannerDialog] 📝 Title changed: "$value"');
                      provider.setTitle(value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Banner Title',
                      border: OutlineInputBorder(),
                      hintText: 'Enter banner title...',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image preview container
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: ColorClass.bgWhite0,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: provider.selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              provider.selectedImage!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'No image selected',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Pick image button
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(context),
                    icon: const Icon(Icons.image),
                    label: Text(provider.selectedImage != null
                        ? 'Change Image'
                        : 'Pick Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorClass.brandDarkGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Create banner button
                  ElevatedButton(
                    onPressed: (provider.isLoading ||
                            provider.title.trim().isEmpty ||
                            provider.selectedImage == null)
                        ? null
                        : () => _submit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorClass.brandDarkGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: provider.isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white)),
                              SizedBox(width: 12),
                              Text('Creating...'),
                            ],
                          )
                        : const Text(
                            'Create Banner',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),

                  // Cancel button
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: provider.isLoading
                        ? null
                        : () {
                            print('[BannerDialog] ❌ Dialog cancelled by user');
                            Navigator.of(context).pop(false);
                          },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
