import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Cloudinary ga unsigned upload preset orqali rasm yuklash.
class CloudinaryService {
  static String get cloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME']?.trim() ?? '';
  static String get uploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET']?.trim() ?? '';

  static bool get isConfigured =>
      cloudName.isNotEmpty && uploadPreset.isNotEmpty;

  static Uri get _uploadUri => Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

  /// Web, mobil va desktop — [XFile.readAsBytes] orqali (dart:io shart emas).
  static Future<String> uploadXFile({
    required XFile file,
    String? folder,
  }) async {
    final bytes = await file.readAsBytes();
    final name = _resolveFilename(file);
    return uploadBytes(bytes: bytes, filename: name, folder: folder);
  }

  static Future<String> uploadBytes({
    required List<int> bytes,
    required String filename,
    String? folder,
  }) async {
    if (!isConfigured) {
      throw Exception(
        'CLOUDINARY_CLOUD_NAME yoki CLOUDINARY_UPLOAD_PRESET .env da topilmadi',
      );
    }

    final request = http.MultipartRequest('POST', _uploadUri)
      ..fields['upload_preset'] = uploadPreset;
    if (folder != null && folder.isNotEmpty) {
      request.fields['folder'] = folder;
    }
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ),
    );

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      debugPrint('CloudinaryUploadError: $body');
      throw Exception('Cloudinary yuklash xatosi (${streamed.statusCode})');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final url = json['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Cloudinary javobida secure_url yo\'q');
    }
    return url;
  }

  static String _resolveFilename(XFile file) {
    if (file.name.isNotEmpty) return file.name;
    final path = file.path;
    if (path.isNotEmpty) {
      final segments = path.split(RegExp(r'[/\\]'));
      if (segments.isNotEmpty && segments.last.isNotEmpty) {
        return segments.last;
      }
    }
    return 'upload.jpg';
  }
}
