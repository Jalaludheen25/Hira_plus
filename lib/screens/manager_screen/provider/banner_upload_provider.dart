import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/do_spaces_config.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/utils/service_utils.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';

class BannerUploadProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  String title = '';
  File? selectedImage;
  bool isLoading = false;

  void setTitle(String value) {
    _logger.i('🏷️ [BANNER] Setting title: $value');
    developer.log('🏷️ Setting banner title: $value', name: 'BannerUploadProvider');
    title = value;
    notifyListeners();
  }

  void setImage(File? file) {
    _logger.i('📷 [BANNER] Setting image: ${file?.path}');
    developer.log('📷 Setting banner image: ${file?.path}', name: 'BannerUploadProvider');
    selectedImage = file;
    notifyListeners();
  }

  Future<String?> uploadToSpaces(File file) async {
    try {
      _logger.i('🚀 [UPLOAD] Starting DigitalOcean Spaces upload');
      developer.log('🚀 Starting DigitalOcean Spaces upload: ${file.path}', name: 'BannerUploadProvider');
      
      final folder = DOSpacesConfig.folder;
      final fileName = '${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}_${file.path.split('/').last}';
      final objectPath = '$folder/$fileName';
      
      _logger.d('📁 [UPLOAD] Folder: $folder');
      _logger.d('📄 [UPLOAD] FileName: $fileName');
      _logger.d('🗂️ [UPLOAD] ObjectPath: $objectPath');
      
      developer.log('📁 Upload details - Folder: $folder, FileName: $fileName', name: 'BannerUploadProvider');
      
      // Use the raw path for URL construction (no encoding here)
      final url = 'https://${DOSpacesConfig.bucket}.${DOSpacesConfig.endpoint}/$objectPath';
      final contentType = _getMimeType(file.path);
      final dateString = HttpDate.format(DateTime.now().toUtc());
      final fileBytes = await file.readAsBytes();
      final contentLength = fileBytes.length;

      _logger.d('🌐 [UPLOAD] URL: $url');
      _logger.d('📝 [UPLOAD] ContentType: $contentType');
      _logger.d('📅 [UPLOAD] Date: $dateString');
      _logger.d('📏 [UPLOAD] ContentLength: $contentLength');

      // Create the string to sign with x-amz-acl header
      final canonicalResource = '/${DOSpacesConfig.bucket}/$objectPath';
      final canonicalizedAmzHeaders = 'x-amz-acl:public-read\n';
      final stringToSign = 'PUT\n\n$contentType\n$dateString\n$canonicalizedAmzHeaders$canonicalResource';
      
      _logger.d('🔏 [UPLOAD] CanonicalResource: $canonicalResource');
      _logger.d('🔏 [UPLOAD] CanonicalizedAmzHeaders: $canonicalizedAmzHeaders');
      _logger.d('📋 [UPLOAD] StringToSign: $stringToSign');
      
      developer.log('🔏 String to sign: $stringToSign', name: 'BannerUploadProvider');

      // Generate signature
      final hmac = Hmac(sha1, utf8.encode(DOSpacesConfig.secret));
      final digest = hmac.convert(utf8.encode(stringToSign));
      final signature = base64.encode(digest.bytes);
      final authHeader = 'AWS ${DOSpacesConfig.key}:$signature';

      _logger.d('🔑 [UPLOAD] Signature: $signature');
      _logger.d('🔐 [UPLOAD] AuthHeader: $authHeader');
      
      developer.log('🔑 Generated signature for upload', name: 'BannerUploadProvider');

      // Make the request
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': authHeader,
          'Date': dateString,
          'Content-Type': contentType,
          'Content-Length': contentLength.toString(),
          'x-amz-acl': 'public-read',
        },
        body: fileBytes,
      );

      _logger.i('📤 [UPLOAD] Response status: ${response.statusCode}');
      _logger.d('📤 [UPLOAD] Response headers: ${response.headers}');
      
      developer.log('📤 Upload response status: ${response.statusCode}', name: 'BannerUploadProvider');

      if (response.statusCode == 200) {
        final publicUrl = '${DOSpacesConfig.cdnEndpoint}/$objectPath';
        _logger.i('✅ [UPLOAD] Upload successful! Public URL: $publicUrl');
        developer.log('✅ Upload successful! Public URL: $publicUrl', name: 'BannerUploadProvider');
        return publicUrl;
      } else {
        _logger.e('❌ [UPLOAD] Upload failed with status ${response.statusCode}');
        _logger.e('❌ [UPLOAD] Error response: ${response.body}');
        developer.log('❌ Upload failed: ${response.statusCode} - ${response.body}', name: 'BannerUploadProvider', error: response.body);
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('💥 [UPLOAD] Exception during upload: $e');
      _logger.e('💥 [UPLOAD] StackTrace: $stackTrace');
      developer.log('💥 Upload exception: $e', name: 'BannerUploadProvider', error: e, stackTrace: stackTrace);
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
    
    _logger.d('🎭 [MIME] File extension: $ext -> MIME type: $mimeType');
    developer.log('🎭 MIME type detected: $ext -> $mimeType', name: 'BannerUploadProvider');
    return mimeType;
  }

  Future<String?> submitBanner() async {
    try {
      _logger.i('🎯 [SUBMIT] Starting banner submission process');
      developer.log('🎯 Starting banner submission process', name: 'BannerUploadProvider');
      
      // Validation
      if (title.trim().isEmpty) {
        _logger.w('⚠️ [SUBMIT] Validation failed: Title is empty');
        developer.log('⚠️ Validation failed: Title is empty', name: 'BannerUploadProvider');
        return 'Please enter a banner title.';
      }
      
      if (selectedImage == null) {
        _logger.w('⚠️ [SUBMIT] Validation failed: No image selected');
        developer.log('⚠️ Validation failed: No image selected', name: 'BannerUploadProvider');
        return 'Please select an image.';
      }

      // Check file size
      final fileSize = await selectedImage!.length();
      if (fileSize > DOSpacesConfig.maxFileSize) {
        _logger.w('⚠️ [SUBMIT] Validation failed: File too large ($fileSize bytes)');
        developer.log('⚠️ Validation failed: File too large ($fileSize bytes)', name: 'BannerUploadProvider');
        return 'Image size must be less than ${(DOSpacesConfig.maxFileSize / 1024 / 1024).toStringAsFixed(1)}MB.';
      }

      _logger.i('✅ [SUBMIT] Validation passed. Title: "${title.trim()}", File size: $fileSize bytes');
      developer.log('✅ Validation passed', name: 'BannerUploadProvider');

      isLoading = true;
      notifyListeners();

      // Step 1: Upload image to DigitalOcean Spaces
      _logger.i('🔄 [SUBMIT] Step 1: Uploading image to DigitalOcean Spaces');
      developer.log('🔄 Step 1: Uploading image to DigitalOcean Spaces', name: 'BannerUploadProvider');
      
      final imageUrl = await uploadToSpaces(selectedImage!);
      
      if (imageUrl == null) {
        isLoading = false;
        notifyListeners();
        _logger.e('❌ [SUBMIT] Step 1 failed: Image upload failed');
        developer.log('❌ Step 1 failed: Image upload failed', name: 'BannerUploadProvider');
        return 'Failed to upload image to cloud storage. Please try again.';
      }

      _logger.i('✅ [SUBMIT] Step 1 completed: Image uploaded to $imageUrl');
      developer.log('✅ Step 1 completed: Image uploaded successfully', name: 'BannerUploadProvider');

      // Step 2: Save banner data to backend
      _logger.i('🔄 [SUBMIT] Step 2: Saving banner data to backend');
      developer.log('🔄 Step 2: Saving banner data to backend', name: 'BannerUploadProvider');
      
      // Try different field name formats that the backend might expect
      final bannerDataOptions = [
        // Option 1: Original format
        {
          'title': title.trim(),
          'bannerImage': imageUrl,
          'createdAt': DateTime.now().toIso8601String(),
        },
        // Option 2: Different field name
        {
          'title': title.trim(),
          'image': imageUrl,
          'createdAt': DateTime.now().toIso8601String(),
        },
        // Option 3: Simplified format
        {
          'title': title.trim(),
          'bannerImage': imageUrl,
        },
        // Option 4: Alternative field name
        {
          'title': title.trim(),
          'imageUrl': imageUrl,
        }
      ];

      // Try each format until one works
      dynamic response;
      String? lastError;
      
      for (int i = 0; i < bannerDataOptions.length; i++) {
        final bannerData = bannerDataOptions[i];
        
        _logger.d('📦 [SUBMIT] Trying banner data format ${i + 1}: $bannerData');
        developer.log('📦 Trying banner data format ${i + 1}', name: 'BannerUploadProvider');

        try {
          response = await HttpServiceUtils.postData(
            ApiUrls.postBanner(), 
            bannerData,
          );
          
          _logger.i('✅ [SUBMIT] Banner data format ${i + 1} worked!');
          developer.log('✅ Banner data format ${i + 1} worked!', name: 'BannerUploadProvider');
          break; // Success, exit the loop
          
        } catch (e) {
          lastError = e.toString();
          _logger.w('⚠️ [SUBMIT] Banner data format ${i + 1} failed: $e');
          developer.log('⚠️ Banner data format ${i + 1} failed: $e', name: 'BannerUploadProvider');
          
          // If this is the last option, throw the error
          if (i == bannerDataOptions.length - 1) {
            throw e;
          }
          // Otherwise, continue to next format
        }
      }

      _logger.i('📨 [SUBMIT] Backend response received');
      _logger.d('📨 [SUBMIT] Response data: $response');
      developer.log('📨 Backend response received', name: 'BannerUploadProvider');

      isLoading = false;
      notifyListeners();

      _logger.i('✅ [SUBMIT] Banner creation completed successfully');
      developer.log('✅ Banner creation completed successfully', name: 'BannerUploadProvider');
      return null; // Success

    } catch (e, stackTrace) {
      isLoading = false;
      notifyListeners();
      
      _logger.e('💥 [SUBMIT] Exception during banner submission: $e');
      _logger.e('💥 [SUBMIT] StackTrace: $stackTrace');
      developer.log('💥 Banner submission exception: $e', name: 'BannerUploadProvider', error: e, stackTrace: stackTrace);
      
      return 'Error creating banner: ${e.toString()}';
    }
  }

  void reset() {
    _logger.i('🔄 [RESET] Resetting banner upload provider');
    developer.log('🔄 Resetting banner upload provider', name: 'BannerUploadProvider');
    
    title = '';
    selectedImage = null;
    isLoading = false;
    notifyListeners();
  }
}