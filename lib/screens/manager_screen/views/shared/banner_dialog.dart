import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/manager_screen/provider/banner_upload_provider.dart';
import 'package:hira_plus/utils/permission_helper.dart';

class BannerDialog extends StatelessWidget {
  const BannerDialog({Key? key}) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    debugPrint('[BannerDialog] 📸 Starting image picker process');

    try {
      final selectedFile =
          await PermissionHelper.pickImageWithPermission(context);

      if (selectedFile != null) {
        final fileSize = await selectedFile.length();
        final fileExtension = selectedFile.path.split('.').last.toLowerCase();

        debugPrint(
            '[BannerDialog] 📁 File selected: ${selectedFile.path}, Size: $fileSize bytes, Type: $fileExtension');

        Provider.of<BannerUploadProvider>(context, listen: false)
            .setImage(selectedFile);
        debugPrint('[BannerDialog] ✅ File set successfully');
      } else {
        debugPrint('[BannerDialog] ❌ No image selected by user');
      }
    } catch (e) {
      debugPrint('[BannerDialog] 💥 Error picking image: $e');

      // Check if context is still valid before showing toast
      if (context.mounted) {
        toastification.show(
          context: context,
          title: Text('Error selecting image: ${e.toString()}'),
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          autoCloseDuration: const Duration(seconds: 3),
          primaryColor: ColorClass.redBase,
          backgroundColor: ColorClass.white,
        );
      }
    }
  }

  void _submit(BuildContext context) async {
    final provider = Provider.of<BannerUploadProvider>(context, listen: false);

    debugPrint('[BannerDialog] 🚀 Starting banner submission');
    debugPrint('[BannerDialog] 📋 Title: "${provider.title}"');
    debugPrint(
        '[BannerDialog] 🖼️ Image selected: ${provider.selectedImage != null}');

    if (provider.selectedImage != null) {
      final file = provider.selectedImage!;
      final fileSize = await file.length();
      debugPrint(
          '[BannerDialog] 📊 Image details: Path=${file.path}, Size=$fileSize bytes');
    }

    final error = await provider.submitBanner();

    if (error == null) {
      debugPrint('[BannerDialog] ✅ Banner created successfully!');
      Navigator.of(context).pop(true);
      toastification.show(
        context: context,
        title: const Text('Banner created successfully!'),
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 2),
        primaryColor: ColorClass.brandDarkGreen,
        backgroundColor: ColorClass.white,
        // foregroundColor: ColorClass.white,
      );
    } else {
      debugPrint('[BannerDialog] ❌ Banner creation failed: $error');
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
        debugPrint('[BannerDialog] 🏗️ Creating BannerUploadProvider');
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
                      debugPrint('[BannerDialog] 📝 Title changed: "$value"');
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
                            debugPrint(
                                '[BannerDialog] ❌ Dialog cancelled by user');
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
