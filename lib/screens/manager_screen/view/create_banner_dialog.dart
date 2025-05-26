import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/constants/do_spaces_config.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:hira_plus/screens/manager_screen/provider/banner_upload_provider.dart';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';

class CreateBannerDialog extends StatelessWidget {
   CreateBannerDialog({Key? key}) : super(key: key);

  final Logger _logger = Logger();

  Future<void> _pickImage(BuildContext context) async {
    try {
      _logger.i('📸 [IMAGE_PICKER] Starting image picker process');
      developer.log('📸 Starting image picker process', name: 'CreateBannerDialog');
      
      // Request permission
      _logger.d('🔐 [IMAGE_PICKER] Requesting photo permission');
      var status = await Permission.photos.request();
      
      _logger.d('🔐 [IMAGE_PICKER] Permission status: $status');
      developer.log('🔐 Photo permission status: $status', name: 'CreateBannerDialog');
      
      if (status.isGranted) {
        _logger.i('✅ [IMAGE_PICKER] Permission granted, opening gallery');
        developer.log('✅ Permission granted, opening gallery', name: 'CreateBannerDialog');
        
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        
        if (pickedFile != null) {
          // Check file size
          final file = File(pickedFile.path);
          final fileSize = await file.length();
          
          _logger.i('📁 [IMAGE_PICKER] Image selected: ${pickedFile.path}');
          _logger.d('📏 [IMAGE_PICKER] File size: $fileSize bytes');
          developer.log('📁 Image selected: ${pickedFile.path}, Size: $fileSize bytes', name: 'CreateBannerDialog');
          
          if (fileSize > DOSpacesConfig.maxFileSize) {
            _logger.w('⚠️ [IMAGE_PICKER] File too large: $fileSize bytes');
            developer.log('⚠️ File too large: $fileSize bytes', name: 'CreateBannerDialog');
            
            _showToast(
              context,
              'Image too large! Please select an image smaller than ${(DOSpacesConfig.maxFileSize / 1024 / 1024).toStringAsFixed(1)}MB.',
              ToastificationType.error,
            );
            return;
          }
          
          Provider.of<BannerUploadProvider>(context, listen: false).setImage(file);
          _logger.i('✅ [IMAGE_PICKER] Image set successfully');
          developer.log('✅ Image set successfully', name: 'CreateBannerDialog');
          
        } else {
          _logger.i('❌ [IMAGE_PICKER] No image selected by user');
          developer.log('❌ No image selected by user', name: 'CreateBannerDialog');
        }
        
      } else if (status.isPermanentlyDenied) {
        _logger.w('🚫 [IMAGE_PICKER] Permission permanently denied');
        developer.log('🚫 Permission permanently denied', name: 'CreateBannerDialog');
        
        _showPermissionDeniedDialog(context);
        
      } else {
        _logger.w('❌ [IMAGE_PICKER] Permission denied');
        developer.log('❌ Permission denied', name: 'CreateBannerDialog');
        
        _showToast(
          context,
          'Permission denied to access photos. Please allow access to select images.',
          ToastificationType.error,
        );
      }
      
    } catch (e, stackTrace) {
      _logger.e('💥 [IMAGE_PICKER] Exception: $e');
      _logger.e('💥 [IMAGE_PICKER] StackTrace: $stackTrace');
      developer.log('💥 Image picker exception: $e', name: 'CreateBannerDialog', error: e, stackTrace: stackTrace);
      
      _showToast(
        context,
        'Error accessing gallery: ${e.toString()}',
        ToastificationType.error,
      );
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'This app needs access to your photos to select banner images. Please grant permission in your device settings.',
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
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) async {
    try {
      _logger.i('🚀 [SUBMIT] Starting banner submission');
      developer.log('🚀 Starting banner submission', name: 'CreateBannerDialog');
      
      final provider = Provider.of<BannerUploadProvider>(context, listen: false);
      final error = await provider.submitBanner();
      
      if (error == null) {
        _logger.i('✅ [SUBMIT] Banner created successfully');
        developer.log('✅ Banner created successfully', name: 'CreateBannerDialog');
        
        Navigator.of(context).pop(true);
        _showToast(
          context,
          'Banner created successfully!',
          ToastificationType.success,
        );
        
        // Reset the provider for next use
        provider.reset();
        
      } else {
        _logger.e('❌ [SUBMIT] Banner creation failed: $error');
        developer.log('❌ Banner creation failed: $error', name: 'CreateBannerDialog');
        
        _showToast(
          context,
          error,
          ToastificationType.error,
        );
      }
      
    } catch (e, stackTrace) {
      _logger.e('💥 [SUBMIT] Exception during submission: $e');
      _logger.e('💥 [SUBMIT] StackTrace: $stackTrace');
      developer.log('💥 Submit exception: $e', name: 'CreateBannerDialog', error: e, stackTrace: stackTrace);
      
      _showToast(
        context,
        'Unexpected error occurred: ${e.toString()}',
        ToastificationType.error,
      );
    }
  }

  void _viewBanners(BuildContext context) async {
    try {
      _logger.i('👀 [VIEW_BANNERS] Starting to fetch and display banners');
      developer.log('👀 Starting to fetch and display banners', name: 'CreateBannerDialog');
      
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            width: 350,
            height: 400,
            child: FutureBuilder<http.Response>(
              future: _fetchBanners(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  _logger.d('⏳ [VIEW_BANNERS] Loading banners...');
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  _logger.e('❌ [VIEW_BANNERS] Error fetching banners: ${snapshot.error}');
                  developer.log('❌ Error fetching banners: ${snapshot.error}', name: 'CreateBannerDialog');
                  return const Center(child: Text('Failed to load banners'));
                }
                
                if (!snapshot.hasData) {
                  _logger.w('⚠️ [VIEW_BANNERS] No data received');
                  return const Center(child: Text('No data received'));
                }
                
                final response = snapshot.data!;
                _logger.d('📨 [VIEW_BANNERS] Response status: ${response.statusCode}');
                
                if (response.statusCode != 200) {
                  _logger.e('❌ [VIEW_BANNERS] HTTP error: ${response.statusCode}');
                  developer.log('❌ HTTP error: ${response.statusCode}', name: 'CreateBannerDialog');
                  return const Center(child: Text('Failed to load banners'));
                }
                
                try {
                  final responseData = json.decode(response.body);
                  final List banners = responseData['data'] ?? responseData ?? [];
                  
                  _logger.i('📊 [VIEW_BANNERS] Loaded ${banners.length} banners');
                  developer.log('📊 Loaded ${banners.length} banners', name: 'CreateBannerDialog');
                  
                  if (banners.isEmpty) {
                    return const Center(child: Text('No banners found'));
                  }
                  
                  return _buildBannersList(context, banners);
                  
                } catch (e) {
                  _logger.e('💥 [VIEW_BANNERS] JSON parsing error: $e');
                  developer.log('💥 JSON parsing error: $e', name: 'CreateBannerDialog');
                  return const Center(child: Text('Error parsing banner data'));
                }
              },
            ),
          ),
        ),
      );
      
    } catch (e, stackTrace) {
      _logger.e('💥 [VIEW_BANNERS] Exception: $e');
      _logger.e('💥 [VIEW_BANNERS] StackTrace: $stackTrace');
      developer.log('💥 View banners exception: $e', name: 'CreateBannerDialog', error: e, stackTrace: stackTrace);
      
      _showToast(
        context,
        'Error loading banners: ${e.toString()}',
        ToastificationType.error,
      );
    }
  }

  Future<http.Response> _fetchBanners() async {
    _logger.d('🌐 [FETCH_BANNERS] Making GET request to ${ApiUrls.getBanner()}');
    developer.log('🌐 Making GET request to fetch banners', name: 'CreateBannerDialog');
    
    final response = await http.get(Uri.parse(ApiUrls.getBanner()));
    
    _logger.d('📨 [FETCH_BANNERS] Response: ${response.statusCode}');
    developer.log('📨 Fetch banners response: ${response.statusCode}', name: 'CreateBannerDialog');
    
    return response;
  }

  Widget _buildBannersList(BuildContext context, List banners) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Uploaded Banners', style: TextStyleClass.poppinsSemiBold(fontSize: 18)),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: banners.length,
              itemBuilder: (context, index) {
                final banner = banners[index];
                return _buildBannerCard(context, banner);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context, Map banner) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          Expanded(
            child: banner['bannerImage'] != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      banner['bannerImage'],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (c, e, s) {
                        _logger.w('🖼️ [BANNER_CARD] Failed to load image: ${banner['bannerImage']}');
                        return const Icon(Icons.broken_image);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  )
                : const Icon(Icons.image_not_supported, size: 60),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              banner['title'] ?? 'Untitled',
              style: TextStyleClass.poppinsMedium(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                tooltip: 'Edit',
                onPressed: () => _editBanner(context, banner),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
                onPressed: () => _deleteBanner(context, banner),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editBanner(BuildContext context, Map banner) async {
    try {
      _logger.i('✏️ [EDIT_BANNER] Starting edit for banner: ${banner['id']}');
      developer.log('✏️ Starting edit for banner: ${banner['id']}', name: 'CreateBannerDialog');
      
      Navigator.of(context).pop(); // Close current dialog
      await _showEditBannerDialog(context, banner);
      
    } catch (e, stackTrace) {
      _logger.e('💥 [EDIT_BANNER] Exception: $e');
      developer.log('💥 Edit banner exception: $e', name: 'CreateBannerDialog', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _deleteBanner(BuildContext context, Map banner) async {
    try {
      _logger.i('🗑️ [DELETE_BANNER] Starting delete confirmation for banner: ${banner['id']}');
      developer.log('🗑️ Starting delete confirmation for banner: ${banner['id']}', name: 'CreateBannerDialog');
      
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Banner'),
          content: Text('Are you sure you want to delete "${banner['title'] ?? 'this banner'}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirm == true) {
        _logger.i('🗑️ [DELETE_BANNER] Deletion confirmed, making DELETE request');
        developer.log('🗑️ Deletion confirmed, making DELETE request', name: 'CreateBannerDialog');
        
        final response = await http.delete(
          Uri.parse(ApiUrls.deleteBanner(banner['id'].toString())),
        );
        
        _logger.d('📨 [DELETE_BANNER] Delete response: ${response.statusCode}');
        developer.log('📨 Delete response: ${response.statusCode}', name: 'CreateBannerDialog');
        
        if (response.statusCode == 200 || response.statusCode == 204) {
          _logger.i('✅ [DELETE_BANNER] Banner deleted successfully');
          developer.log('✅ Banner deleted successfully', name: 'CreateBannerDialog');
          
          _showToast(
            context,
            'Banner deleted successfully!',
            ToastificationType.success,
          );
          _viewBanners(context); // Refresh list
          
        } else {
          _logger.e('❌ [DELETE_BANNER] Delete failed: ${response.statusCode} - ${response.body}');
          developer.log('❌ Delete failed: ${response.statusCode}', name: 'CreateBannerDialog');
          
          _showToast(
            context,
            'Failed to delete banner. Please try again.',
            ToastificationType.error,
          );
        }
      }
      
    } catch (e, stackTrace) {
      _logger.e('💥 [DELETE_BANNER] Exception: $e');
      _logger.e('💥 [DELETE_BANNER] StackTrace: $stackTrace');
      developer.log('💥 Delete banner exception: $e', name: 'CreateBannerDialog', error: e, stackTrace: stackTrace);
      
      _showToast(
        context,
        'Error deleting banner: ${e.toString()}',
        ToastificationType.error,
      );
    }
  }

  Future<void> _showEditBannerDialog(BuildContext context, Map banner) async {
    final titleController = TextEditingController(text: banner['title'] ?? '');
    String? imageUrl = banner['bannerImage'];
    bool isLoading = false;
    
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: const Text('Edit Banner'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (imageUrl != null)
                  Image.network(
                    imageUrl,
                    height: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: isLoading ? null : () async {
                  try {
                    setState(() => isLoading = true);
                    
                    _logger.i('💾 [EDIT_BANNER] Saving banner edits: ${banner['id']}');
                    developer.log('💾 Saving banner edits: ${banner['id']}', name: 'CreateBannerDialog');
                    
                    final response = await http.put(
                      Uri.parse(ApiUrls.editBanner(banner['id'].toString())),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'title': titleController.text.trim(),
                        'bannerImage': imageUrl,
                      }),
                    );
                    
                    _logger.d('📨 [EDIT_BANNER] Edit response: ${response.statusCode}');
                    developer.log('📨 Edit response: ${response.statusCode}', name: 'CreateBannerDialog');
                    
                    setState(() => isLoading = false);
                    
                    if (response.statusCode == 200 || response.statusCode == 204) {
                      _logger.i('✅ [EDIT_BANNER] Banner updated successfully');
                      developer.log('✅ Banner updated successfully', name: 'CreateBannerDialog');
                      
                      _showToast(
                        context,
                        'Banner updated successfully!',
                        ToastificationType.success,
                      );
                      Navigator.of(ctx).pop();
                      _viewBanners(context); // Refresh list
                      
                    } else {
                      _logger.e('❌ [EDIT_BANNER] Update failed: ${response.statusCode} - ${response.body}');
                      developer.log('❌ Update failed: ${response.statusCode}', name: 'CreateBannerDialog');
                      
                      _showToast(
                        context,
                        'Failed to update banner. Please try again.',
                        ToastificationType.error,
                      );
                    }
                    
                  } catch (e, stackTrace) {
                    setState(() => isLoading = false);
                    _logger.e('💥 [EDIT_BANNER] Exception: $e');
                    developer.log('💥 Edit exception: $e', name: 'CreateBannerDialog', error: e, stackTrace: stackTrace);
                    
                    _showToast(
                      context,
                      'Error updating banner: ${e.toString()}',
                      ToastificationType.error,
                    );
                  }
                },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showToast(BuildContext context, String message, ToastificationType type) {
    final backgroundColor = type == ToastificationType.success 
        ? ColorClass.brandDarkGreen 
        : Colors.red;
        
    toastification.show(
      context: context,
      title: Text(message),
      type: type,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: const Duration(seconds: 3),
      backgroundColor: backgroundColor,
      foregroundColor: ColorClass.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('🏗️ [BUILD] Building CreateBannerDialog');
    developer.log('🏗️ Building CreateBannerDialog', name: 'CreateBannerDialog');
    
    return ChangeNotifierProvider(
      create: (_) {
        _logger.d('🏭 [BUILD] Creating BannerUploadProvider');
        return BannerUploadProvider();
      },
      child: Consumer<BannerUploadProvider>(
        builder: (context, provider, _) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Create Banner', style: TextStyleClass.poppinsSemiBold(fontSize: 20)),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: provider.setTitle,
                    decoration: const InputDecoration(
                      labelText: 'Banner Title *',
                      border: OutlineInputBorder(),
                      hintText: 'Enter a catchy title for your banner',
                    ),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: ColorClass.bgWhite0,
                      border: Border.all(color: ColorClass.neutral200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: provider.selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              provider.selectedImage!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('No image selected', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  // Test connection button (for debugging)
                  if (kDebugMode) ...[
                    OutlinedButton.icon(
                      onPressed: () async {
                        _logger.i('🧪 [TEST] Testing DigitalOcean Spaces connection');
                        developer.log('🧪 Testing DigitalOcean Spaces connection', name: 'CreateBannerDialog');
                        
                        // Add the test function from the previous artifact to your banner_upload_provider.dart
                        // Then call: await BannerUploadProvider.testSpacesConnection();
                        
                        _showToast(
                          context,
                          'Check console logs for Spaces test results',
                          ToastificationType.info,
                        );
                      },
                      icon: const Icon(Icons.wifi_tethering),
                      label: const Text('Test Spaces'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        _logger.i('🧪 [DEBUG] Testing backend API expectations');
                        developer.log('🧪 Testing backend API expectations', name: 'CreateBannerDialog');
                        
                        // Add the debug function from the previous artifact to your banner_upload_provider.dart
                        // Then call: await BannerUploadProvider.debugBackendAPI();
                        
                        _showToast(
                          context,
                          'Check console logs for API test results',
                          ToastificationType.info,
                        );
                      },
                      icon: const Icon(Icons.api),
                      label: const Text('Debug API'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple,
                        side: const BorderSide(color: Colors.purple),
                      ),
                    ),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: provider.isLoading ? null : () => _pickImage(context),
                          icon: const Icon(Icons.image),
                          label: const Text('Pick Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorClass.brandDarkGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _viewBanners(context),
                          icon: const Icon(Icons.visibility),
                          label: const Text('View Banners'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorClass.brandDarkGreen,
                            side: BorderSide(color: ColorClass.brandDarkGreen),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: (provider.isLoading || 
                                 provider.title.trim().isEmpty || 
                                 provider.selectedImage == null) 
                        ? null 
                        : () => _submit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorClass.brandDarkGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: provider.isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20, 
                                height: 20, 
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, 
                                  color: Colors.white
                                )
                              ),
                              SizedBox(width: 12),
                              Text('Creating Banner...'),
                            ],
                          )
                        : const Text('Create Banner'),
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