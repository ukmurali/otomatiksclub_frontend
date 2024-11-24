import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:otomatiksclub/config/app_config.dart';
import 'package:mime/mime.dart';

class ApiImageService {
  static final DefaultCacheManager _cacheManager = DefaultCacheManager();

  static Future<http.Response> uploadImage(
      String action, File mediaFile, bool isVideoType, String? fileId, String userIdValue) async {
    const String url = '${AppConfig.apiUrl}/upload';
    final Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
    };

    // Get the file's MIME type (image/jpeg, image/png, etc.)
    final mimeTypeData =
        lookupMimeType(mediaFile.path, headerBytes: [0xFF, 0xD8])?.split('/');

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(headers);

    if (fileId != null) {
      request.fields['fileId'] =
          fileId; // Adding the fileId parameter only if it's not null
    } else {
      request.fields['fileId'] = "";
    }
    request.fields['userId'] = userIdValue;
     request.fields['action'] = action;
    request.files.add(await http.MultipartFile.fromPath(
      'file', // Name of the parameter expected by the backend
      mediaFile.path,
      contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
    ));

    // Send the request
    var streamedResponse = await request.send();

    // Get the response
    var response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  static Future<Uint8List?> fetchImage(String? fileId) async {
    final url = '${AppConfig.apiUrl}/download/$fileId';

    // Check if the image is in the cache
    final fileInfo = await _cacheManager.getFileFromCache(url);
    if (fileInfo != null) {
      // Return cached image bytes
      return fileInfo.file.readAsBytesSync();
    } else {
      // If not cached, download the image
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Cache the image bytes
        await _cacheManager.putFile(url, response.bodyBytes);
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image');
      }
    }
  }
}
