import 'dart:developer' as developer;

class DOSpacesConfig {
  static const String key = 'DO801A7DUB7X6AGZA3P2';
  static const String secret = 'ofkGE22/HEqYgzOBWHQUQwQEWrtbAEMJJen898rOYx4';
  static const String endpoint = 'blr1.digitaloceanspaces.com';
  static const String cdnEndpoint = 'https://d4dx-storage.blr1.cdn.digitaloceanspaces.com';
  static const String bucket = 'd4dx-storage';
  static const String folder = 'hira_plus_banner';
  static const int maxFileSize = 5242880; // 5MB in bytes

  /// Validate configuration
  static bool validateConfig() {
    developer.log('🔍 [DO_SPACES] Validating DigitalOcean Spaces configuration', name: 'DOSpacesConfig');
    
    final isValid = key.isNotEmpty &&
                   secret.isNotEmpty &&
                   endpoint.isNotEmpty &&
                   cdnEndpoint.isNotEmpty &&
                   bucket.isNotEmpty &&
                   folder.isNotEmpty &&
                   maxFileSize > 0;
    
    if (isValid) {
      developer.log('✅ [DO_SPACES] Configuration validation passed', name: 'DOSpacesConfig');
    } else {
      developer.log('❌ [DO_SPACES] Configuration validation failed', name: 'DOSpacesConfig');
    }
    
    return isValid;
  }

  /// Get formatted max file size string
  static String getMaxFileSizeString() {
    final sizeInMB = (maxFileSize / 1024 / 1024).toStringAsFixed(1);
    return '${sizeInMB}MB';
  }

  /// Check if file size is within limits
  static bool isFileSizeValid(int fileSizeBytes) {
    final isValid = fileSizeBytes <= maxFileSize;
    developer.log('📏 [DO_SPACES] File size validation: ${isValid ? 'PASSED' : 'FAILED'} ($fileSizeBytes bytes)', name: 'DOSpacesConfig');
    return isValid;
  }
}