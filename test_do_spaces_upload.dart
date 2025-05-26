import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

void main() async {
  // TODO: Replace these with your actual values
  final key = 'DO801A7DUB7X6AGZA3P2';
  final secret = 'ofkGE22/HEqYgzOBWHQUQwQEWrtbAEMJJen898rOYx4';
  final bucket = 'd4dx-storage';
  final endpoint = 'blr1.digitaloceanspaces.com';
  final filePath = 'test.jpg'; // Path to a small test image in your project root
  final fileName = 'test_upload.jpg'; // Name to use in Spaces

  final file = File(filePath);
  if (!await file.exists()) {
    print('File not found: $filePath');
    return;
  }
  final contentType = 'image/jpeg';
  final date = HttpDate.format(DateTime.now().toUtc());
  final fileBytes = await file.readAsBytes();

  final stringToSign = 'PUT\n\n$contentType\n$date\n/$bucket/$fileName';
  print('stringToSign:\n$stringToSign');
  final hmac = Hmac(sha1, utf8.encode(secret));
  final signature = base64.encode(hmac.convert(utf8.encode(stringToSign)).bytes);
  final authHeader = 'AWS $key:$signature';

  final url = 'https://$bucket.$endpoint/$fileName';
  print('Uploading to: $url');

  final response = await http.put(
    Uri.parse(url),
    headers: {
      'Authorization': authHeader,
      'Date': date,
      'Content-Type': contentType,
      'Content-Length': fileBytes.length.toString(),
      'x-amz-acl': 'public-read',
    },
    body: fileBytes,
  );
  print('Response: ${response.statusCode}');
  print('Body: ${response.body}');
} 