import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:stem_club/config/config.dart';
import 'package:mime/mime.dart';

class ApiImageService {
  static Future<http.Response> uploadImage(File imageFile) async {
    var compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.path, // original file path
      '${imageFile.path}_compressed.jpg', // compressed file path
      quality: 80, // compression quality
    );
    const String url = '${Config.apiUrl}/upload/image';
    final Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
    };

    // Get the file's MIME type (image/jpeg, image/png, etc.)
    final mimeTypeData =
        lookupMimeType(compressedFile!.path, headerBytes: [0xFF, 0xD8])?.split('/');

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath(
        'file', // Name of the parameter expected by the backend
        compressedFile.path,
        contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
      ));

    // Send the request
    var streamedResponse = await request.send();

    // Get the response
    var response = await http.Response.fromStream(streamedResponse);
    return response;
  }
}
