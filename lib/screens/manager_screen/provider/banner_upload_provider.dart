import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/utils/service_utils.dart';
import 'package:hira_plus/utils/shared_utils.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class BannerUploadProvider extends ChangeNotifier {
  String title = '';
  File? selectedImage;
  bool isLoading = false;

  void setTitle(String value) {
    debugPrint('[BannerUploadProvider] 📝 Setting title: "$value"');
    title = value;
    notifyListeners();
  }

  void setImage(File? file) {
    if (file != null) {
      debugPrint('[BannerUploadProvider] 🖼️ Setting image: ${file.path}');
      debugPrint('[BannerUploadProvider] 📊 File exists: ${file.existsSync()}');
      if (file.existsSync()) {
        final sizeInBytes = file.lengthSync();
        final sizeInMB = (sizeInBytes / (1024 * 1024)).toStringAsFixed(2);
        debugPrint(
            '[BannerUploadProvider] 📏 File size: $sizeInBytes bytes ($sizeInMB MB)');
      }
    } else {
      debugPrint('[BannerUploadProvider] ❌ Setting image to null');
    }
    selectedImage = file;
    notifyListeners();
  }

  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    final mimeType = switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'bmp' => 'image/bmp',
      'svg' => 'image/svg+xml',
      _ => 'application/octet-stream',
    };
    debugPrint(
        '[BannerUploadProvider] 🏷️ File extension: $ext, MIME type: $mimeType');
    return mimeType;
  }

  Future<String?> submitBanner() async {
    debugPrint('[BannerUploadProvider] 🚀 Starting banner submission');
    debugPrint('[BannerUploadProvider] 📋 Title: "$title"');
    debugPrint(
        '[BannerUploadProvider] 🖼️ Image selected: ${selectedImage != null}');

    // Validation
    if (title.trim().isEmpty) {
      debugPrint('[BannerUploadProvider] ❌ Title is empty');
      return 'Please enter a banner title.';
    }

    if (selectedImage == null) {
      debugPrint('[BannerUploadProvider] ❌ No image selected');
      return 'Please select an image.';
    }

    if (!selectedImage!.existsSync()) {
      debugPrint('[BannerUploadProvider] ❌ Selected image file does not exist');
      return 'Selected image file is not accessible.';
    }

    isLoading = true;
    notifyListeners();

    try {
      // Create multipart request
      final url = ApiUrls.postBanner();
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add auth token if available
      final token = await SharedUtils.getString('auth_token');
      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add title field
      request.fields['title'] = title.trim();

      // Add image file
      final file = selectedImage!;
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        'bannerImage',
        stream,
        length,
        filename: file.path.split('/').last,
        contentType: MediaType.parse(_getMimeType(file.path)),
      );
      request.files.add(multipartFile);

      debugPrint('[BannerUploadProvider] 📤 Sending multipart request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint(
          '[BannerUploadProvider] 📡 Upload response status: ${response.statusCode}');
      debugPrint('[BannerUploadProvider] 📡 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[BannerUploadProvider] ✅ Banner created successfully');
        isLoading = false;
        notifyListeners();
        return null; // Success
      } else {
        final error = 'Upload failed with status: ${response.statusCode}';
        debugPrint('[BannerUploadProvider] ❌ $error');
        isLoading = false;
        notifyListeners();
        return error;
      }
    } catch (e, stackTrace) {
      debugPrint('[BannerUploadProvider] 💥 Exception during upload: $e');
      debugPrint('[BannerUploadProvider] 📚 Stack trace: $stackTrace');

      isLoading = false;
      notifyListeners();
      return 'Error creating banner: ${e.toString()}';
    }
  }
}
