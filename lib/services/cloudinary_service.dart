import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Cloudinary ga upload preset orqali rasm/fayl yuklash (unsigned yoki signed).
class CloudinaryService {
  static String get cloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME']?.trim() ?? '';
  static String get uploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET']?.trim() ?? '';
  static String get apiKey =>
      dotenv.env['CLOUDINARY_API_KEY']?.trim() ?? '';
  static String get apiSecret =>
      dotenv.env['CLOUDINARY_API_SECRET']?.trim() ?? '';

  static bool get isConfigured =>
      cloudName.isNotEmpty && uploadPreset.isNotEmpty;

  static bool get _canSignUpload =>
      apiKey.isNotEmpty && apiSecret.isNotEmpty;

  /// Rasm uchun endpoint
  static Uri get _imageUploadUri => Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

  /// Har qanday fayl uchun endpoint (raw)
  static Uri get _rawUploadUri => Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/raw/upload',
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

  /// Bytes orqali rasm yuklash
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
    if (_canSignUpload) {
      return _uploadSigned(
          bytes: bytes, filename: filename, folder: folder, isRaw: false);
    }
    return _uploadUnsigned(
        bytes: bytes, filename: filename, folder: folder, isRaw: false);
  }

  /// Har qanday fayl (PDF, DOCX, va h.k.) yuklash
  static Future<String> uploadRawFile({
    required List<int> bytes,
    required String filename,
    String? folder,
  }) async {
    if (!isConfigured) {
      throw Exception(
        'CLOUDINARY_CLOUD_NAME yoki CLOUDINARY_UPLOAD_PRESET .env da topilmadi',
      );
    }
    if (_canSignUpload) {
      return _uploadSigned(
          bytes: bytes, filename: filename, folder: folder, isRaw: true);
    }
    return _uploadUnsigned(
        bytes: bytes, filename: filename, folder: folder, isRaw: true);
  }

  static Future<String> _uploadUnsigned({
    required List<int> bytes,
    required String filename,
    String? folder,
    bool isRaw = false,
  }) async {
    final uri = isRaw ? _rawUploadUri : _imageUploadUri;
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset;
    if (folder != null && folder.isNotEmpty) {
      request.fields['folder'] = folder;
    }
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );
    return _send(request);
  }

  static Future<String> _uploadSigned({
    required List<int> bytes,
    required String filename,
    String? folder,
    bool isRaw = false,
  }) async {
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    final paramsToSign = <String, String>{
      'timestamp': timestamp,
      'upload_preset': uploadPreset,
    };
    if (folder != null && folder.isNotEmpty) {
      paramsToSign['folder'] = folder;
    }

    final uri = isRaw ? _rawUploadUri : _imageUploadUri;
    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = apiKey
      ..fields['timestamp'] = timestamp
      ..fields['signature'] = _signParams(paramsToSign)
      ..fields['upload_preset'] = uploadPreset;

    if (folder != null && folder.isNotEmpty) {
      request.fields['folder'] = folder;
    }

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    try {
      return await _send(request);
    } on Exception catch (e) {
      if (e.toString().contains('401') && uploadPreset.isNotEmpty) {
        debugPrint('Cloudinary signed upload failed, trying unsigned: $e');
        return _uploadUnsigned(
          bytes: bytes,
          filename: filename,
          folder: folder,
          isRaw: isRaw,
        );
      }
      rethrow;
    }
  }

  static String _signParams(Map<String, String> params) {
    final keys = params.keys.toList()..sort();
    final payload = keys.map((k) => '$k=${params[k]}').join('&');
    return sha1.convert(utf8.encode('$payload$apiSecret')).toString();
  }

  static Future<String> _send(http.MultipartRequest request) async {
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      debugPrint('CloudinaryUploadError: $body');
      throw Exception(_parseError(body, streamed.statusCode));
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final url = json['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Cloudinary javobida secure_url yo\'q');
    }
    return url;
  }

  static String _parseError(String body, int statusCode) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        final err = json['error'];
        if (err is Map && err['message'] != null) {
          return 'Cloudinary ($statusCode): ${err['message']}';
        }
        if (json['message'] != null) {
          return 'Cloudinary ($statusCode): ${json['message']}';
        }
      }
    } catch (_) {}
    if (statusCode == 401) {
      return 'Cloudinary (401): Cloud name, API kalit yoki upload preset noto\'g\'ri. '
          'Console → Settings → Upload presets da preset nomini tekshiring.';
    }
    return 'Cloudinary yuklash xatosi ($statusCode)';
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
