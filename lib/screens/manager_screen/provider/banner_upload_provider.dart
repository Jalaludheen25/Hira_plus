import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/do_spaces_config.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/utils/service_utils.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class BannerUploadProvider extends ChangeNotifier {
  String title = '';
  File? selectedImage;
  bool isLoading = false;

  void setTitle(String value) {
    print('[BannerUploadProvider] 📝 Setting title: "$value"');
    title = value;
    notifyListeners();
  }

  void setImage(File? file) {
    if (file != null) {
      print('[BannerUploadProvider] 🖼️ Setting image: ${file.path}');
      print('[BannerUploadProvider] 📊 File exists: ${file.existsSync()}');
      if (file.existsSync()) {
        final sizeInBytes = file.lengthSync();
        final sizeInMB = (sizeInBytes / (1024 * 1024)).toStringAsFixed(2);
        print('[BannerUploadProvider] 📏 File size: $sizeInBytes bytes ($sizeInMB MB)');
      }
    } else {
      print('[BannerUploadProvider] ❌ Setting image to null');
    }
    selectedImage = file;
    notifyListeners();
  }

  Future<String?> uploadToSpaces(File file) async {
    print('[BannerUploadProvider] 🚀 Starting upload to DigitalOcean Spaces');
    print('[BannerUploadProvider] 📁 File path: ${file.path}');
    print('[BannerUploadProvider] 📊 File exists: ${file.existsSync()}');
    
    if (!file.existsSync()) {
      print('[BannerUploadProvider] ❌ File does not exist!');
      return null;
    }

    try {
      // Get current UTC time
      final now = DateTime.now().toUtc();
      print('[BannerUploadProvider] ⏰ Current UTC time: $now');
      
      // Create a clean filename without special characters
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
      final originalName = file.path.split('/').last;
      final cleanName = originalName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final fileName = '${timestamp}_$cleanName';
      
      print('[BannerUploadProvider] 📄 Original filename: $originalName');
      print('[BannerUploadProvider] 📄 Clean filename: $fileName');

      final folder = DOSpacesConfig.folder;
      final objectKey = '$folder/$fileName'; // This is the S3 object key
      
      print('[BannerUploadProvider] 📂 Bucket: ${DOSpacesConfig.bucket}');
      print('[BannerUploadProvider] 📂 Folder: $folder');
      print('[BannerUploadProvider] 🔑 Object key: $objectKey');

      // Build the URL - no encoding for the URL construction
      final host = '${DOSpacesConfig.bucket}.${DOSpacesConfig.endpoint}';
      final url = 'https://$host/$objectKey';
      print('[BannerUploadProvider] 🌐 Upload URL: $url');

      final contentType = _getMimeType(file.path);
      final dateHeader = HttpDate.format(now);
      final fileBytes = await file.readAsBytes();
      final contentLength = fileBytes.length;

      print('[BannerUploadProvider] 📋 Content type: $contentType');
      print('[BannerUploadProvider] 📅 Date header: $dateHeader');
      print('[BannerUploadProvider] 📏 Content length: $contentLength bytes');

      // Create the canonical string to sign for AWS Signature Version 2
      // Format: HTTP-VERB + "\n" + Content-MD5 + "\n" + Content-Type + "\n" + Date + "\n" + CanonicalizedAmzHeaders + CanonicalizedResource
      final canonicalizedResource = '/${DOSpacesConfig.bucket}/$objectKey';
      final stringToSign = 'PUT\n\n$contentType\n$dateHeader\nx-amz-acl:public-read\n$canonicalizedResource';
      
      print('[BannerUploadProvider] 🔐 Canonicalized resource: $canonicalizedResource');
      print('[BannerUploadProvider] 🔐 String to sign:');
      print('[BannerUploadProvider] ────────────────────');
      print('[BannerUploadProvider] $stringToSign');
      print('[BannerUploadProvider] ────────────────────');
      
      // Calculate HMAC-SHA1 signature
      final hmac = Hmac(sha1, utf8.encode(DOSpacesConfig.secret));
      final digest = hmac.convert(utf8.encode(stringToSign));
      final signature = base64.encode(digest.bytes);
      final authHeader = 'AWS ${DOSpacesConfig.key}:$signature';
      
      print('[BannerUploadProvider] 🔑 Access key: ${DOSpacesConfig.key}');
      print('[BannerUploadProvider] 🔒 Secret key length: ${DOSpacesConfig.secret.length} chars');
      print('[BannerUploadProvider] 🔐 Calculated signature: $signature');
      print('[BannerUploadProvider] 🔐 Authorization header: $authHeader');

      // Prepare headers
      final headers = {
        'Host': host,
        'Authorization': authHeader,
        'Date': dateHeader,
        'Content-Type': contentType,
        'Content-Length': contentLength.toString(),
        'x-amz-acl': 'public-read',
      };
      
      print('[BannerUploadProvider] 📋 All headers:');
      headers.forEach((key, value) {
        print('[BannerUploadProvider] 📋   $key: $value');
      });

      // Make the PUT request
      print('[BannerUploadProvider] 📡 Making PUT request...');
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: fileBytes,
      );

      print('[BannerUploadProvider] 📡 Upload response status: ${response.statusCode}');
      print('[BannerUploadProvider] 📡 Upload response headers: ${response.headers}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final finalUrl = '${DOSpacesConfig.cdnEndpoint}/$objectKey';
        print('[BannerUploadProvider] ✅ Upload successful!');
        print('[BannerUploadProvider] 🔗 Final CDN URL: $finalUrl');
        return finalUrl;
      } else {
        print('[BannerUploadProvider] ❌ Upload failed with status: ${response.statusCode}');
        print('[BannerUploadProvider] 📄 Error response body: ${response.body}');
        
        // Parse XML error for better debugging
        try {
          if (response.body.contains('<Code>')) {
            final codeMatch = RegExp(r'<Code>(.*?)</Code>').firstMatch(response.body);
            final messageMatch = RegExp(r'<Message>(.*?)</Message>').firstMatch(response.body);
            
            if (codeMatch != null) {
              print('[BannerUploadProvider] 🚨 Error code: ${codeMatch.group(1)}');
            }
            if (messageMatch != null) {
              print('[BannerUploadProvider] 💬 Error message: ${messageMatch.group(1)}');
            }
          }
        } catch (e) {
          print('[BannerUploadProvider] ⚠️ Could not parse XML error: $e');
        }
        
        return null;
      }
    } catch (e, stackTrace) {
      print('[BannerUploadProvider] 💥 Exception during upload: $e');
      print('[BannerUploadProvider] 📚 Stack trace: $stackTrace');
      return null;
    }
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
    print('[BannerUploadProvider] 🏷️ File extension: $ext, MIME type: $mimeType');
    return mimeType;
  }

  // Alternative upload method using presigned URL (if the direct upload keeps failing)
  Future<String?> uploadWithPresignedUrl(File file) async {
    print('[BannerUploadProvider] 🔄 Attempting upload with presigned URL method');
    
    try {
      // You would need to implement an API endpoint that generates presigned URLs
      // This is a more secure and reliable method for uploads
      
      // For now, return null to fall back to direct upload
      return null;
    } catch (e) {
      print('[BannerUploadProvider] ❌ Presigned URL upload failed: $e');
      return null;
    }
  }

  Future<String?> submitBanner() async {
    print('[BannerUploadProvider] 🚀 Starting banner submission');
    print('[BannerUploadProvider] 📋 Title: "$title"');
    print('[BannerUploadProvider] 🖼️ Image selected: ${selectedImage != null}');
    
    // Validation
    if (title.trim().isEmpty) {
      print('[BannerUploadProvider] ❌ Title is empty');
      return 'Please enter a banner title.';
    }
    
    if (selectedImage == null) {
      print('[BannerUploadProvider] ❌ No image selected');
      return 'Please select an image.';
    }

    if (!selectedImage!.existsSync()) {
      print('[BannerUploadProvider] ❌ Selected image file does not exist');
      return 'Selected image file is not accessible.';
    }

    // Check file size
    final fileSize = selectedImage!.lengthSync();
    print('[BannerUploadProvider] 📏 File size: $fileSize bytes');
    if (fileSize > DOSpacesConfig.maxFileSize) {
      final maxSizeMB = (DOSpacesConfig.maxFileSize / (1024 * 1024)).toStringAsFixed(1);
      final currentSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
      print('[BannerUploadProvider] ❌ File too large: ${currentSizeMB}MB > ${maxSizeMB}MB');
      return 'Image is too large. Maximum size is ${maxSizeMB}MB, but selected image is ${currentSizeMB}MB.';
    }

    isLoading = true;
    notifyListeners();
    
    try {
      print('[BannerUploadProvider] 📤 Starting image upload...');
      String? imageUrl = await uploadToSpaces(selectedImage!);
      
      // If direct upload fails, you could try alternative methods here
      if (imageUrl == null) {
        print('[BannerUploadProvider] 🔄 Direct upload failed, checking alternatives...');
        // imageUrl = await uploadWithPresignedUrl(selectedImage!);
      }
      
      if (imageUrl == null) {
        print('[BannerUploadProvider] ❌ All upload methods failed');
        isLoading = false;
        notifyListeners();
        return 'Image upload failed. Please verify your DigitalOcean Spaces configuration and try again.';
      }

      print('[BannerUploadProvider] ✅ Image uploaded successfully: $imageUrl');
      print('[BannerUploadProvider] 📡 Sending banner data to API...');

      // Prepare data for API
      final data = {
        'title': title.trim(),
        'bannerImage': imageUrl,
      };
      
      print('[BannerUploadProvider] 📦 API payload: $data');
      
      final response = await HttpServiceUtils.postData(ApiUrls.postBanner(), data);
      print('[BannerUploadProvider] 📡 API response: $response');
      
      isLoading = false;
      notifyListeners();
      
      print('[BannerUploadProvider] ✅ Banner submission completed successfully');
      return null; // Success
      
    } catch (e, stackTrace) {
      print('[BannerUploadProvider] 💥 Exception during banner submission: $e');
      print('[BannerUploadProvider] 📚 Stack trace: $stackTrace');
      
      isLoading = false;
      notifyListeners();
      
      return 'Error creating banner: ${e.toString()}';
    }
  }
}