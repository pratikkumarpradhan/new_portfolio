// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;

// Future<String> uploadImageToCloudinary(File imageFile) async {
//   final cloudName = 'dyp8u0ka1';
//   final uploadPreset = 'portfolio';

//   final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

//   final request = http.MultipartRequest('POST', uri)
//     ..fields['upload_preset'] = uploadPreset
//     ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

//   final response = await request.send();
//   final resStr = await response.stream.bytesToString();
//   final json = jsonDecode(resStr);

//   if (response.statusCode == 200) {
//     return json['secure_url']; // 🎉
//   } else {
//     throw Exception('Failed to upload image: $resStr');
//   }
// }


import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

Future<String> uploadToCloudinary(XFile file) async {
  const cloudName = 'dyp8u0ka1';
  const uploadPreset = 'project';
  final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..fields['folder'] = 'project'; // 👈 Ensure it uploads to project/ folder

  try {
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    final response = await request.send();
    final res = await http.Response.fromStream(response);
    final data = jsonDecode(res.body);

    if (response.statusCode == 200) {
      debugPrint('✅ Uploaded to Cloudinary: ${data['secure_url']}');
      return data['secure_url'];
    } else {
      debugPrint('❌ Cloudinary error: ${data['error']['message']}');
      throw Exception("Upload failed: ${data['error']['message']}");
    }
  } catch (e) {
    debugPrint('❌ Exception during Cloudinary upload: $e');
    rethrow;
  }
}

Future<String> uploadSvgToCloudinary(XFile file) async {
  const cloudName = 'dyp8u0ka1';
  const uploadPreset = 'skills';
  final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/upload");

  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..fields['folder'] = 'skills'
    ..fields['resource_type'] = 'raw';

  try {
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name,
        contentType: MediaType('image', 'svg+xml'),
      );
      request.files.add(multipartFile);
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    final response = await request.send();
    final res = await http.Response.fromStream(response);
    final data = jsonDecode(res.body);

    if (response.statusCode == 200) {
      debugPrint('✅ Uploaded SVG to Cloudinary: ${data['secure_url']}');
      return data['secure_url'];
    } else {
      debugPrint('❌ Cloudinary SVG error: ${data['error']['message']}');
      throw Exception("SVG upload failed: ${data['error']['message']}");
    }
  } catch (e) {
    debugPrint('❌ Exception during Cloudinary SVG upload: $e');
    rethrow;
  }
}