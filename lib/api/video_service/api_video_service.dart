import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:stem_club/config/app_config.dart';

class ApiVideoService {
  static Future<http.Response> uploadVideo(
      File videoFile, String title, String description) async {
    const String url = '${AppConfig.apiUrl}/upload';
    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files
        .add(await http.MultipartFile.fromPath('file', videoFile.path));
    request.fields['title'] = title;
    request.fields['description'] = description;

    // Send the request
    var streamedResponse = await request.send();

    // Get the response
    var response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  static Future<http.Response> verifyGoogleAuthorization(
      File videoFile, String title, String description) async {
    const url = '${AppConfig.apiUrl}/authorization';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print('response: ${response.body}');
      throw Exception('Failed to upload');
      //return await uploadVideo(videoFile, title, description);
    } else {
      throw Exception('Failed to upload');
    }
  }
}
