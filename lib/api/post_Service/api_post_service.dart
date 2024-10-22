import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:stem_club/api/image_service/api_image_service.dart';
import 'package:stem_club/config/app_config.dart';
import 'package:stem_club/utils/user_auth_data.dart';
import 'dart:developer' as developer;

import '../api_client.dart'; // Import your custom API client

class ApiPostService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> createPost(
      File? imageFile, Map<String, dynamic> formData) async {
    try {
      http.Response? imageResponse;
      if (imageFile != null) {
        // Upload the image and await the response
        imageResponse = await ApiImageService.uploadImage(imageFile);

        // Check if the image upload was successful
        if (imageResponse.statusCode != 200) {
          return {
            'statusCode': imageResponse.statusCode,
            'body': 'Image upload failed: ${imageResponse.body}'
          };
        }
      }
      // Fetch user authentication data
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;

      // Prepare the form data
      formData['userId'] = userId;
      if (imageResponse != null) {
        formData['postUrl'] = imageResponse.body;
      }

      const url = '${AppConfig.apiUrl}/posts';
      final response = await _apiClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(formData),
      );

      return {'statusCode': response.statusCode, 'body': response.body};
    } catch (e) {
      // Handle errors
      developer.log('create post error: $e');
      return {'statusCode': 500, 'body': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> getAllPost(bool isAllPost) async {
    try {
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      final url =
          '${AppConfig.apiUrl}/posts?userId=$userId&isAllPost=$isAllPost';
      final response = await _apiClient.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      return {'statusCode': response.statusCode, 'body': response.body};
    } catch (e) {
      // Handle errors
      developer.log('verify otp error: $e');
      return {'statusCode': 500, 'body': e.toString()};
    }
  }
}
