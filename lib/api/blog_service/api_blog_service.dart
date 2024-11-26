import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:otomatiksclub/api/image_service/api_image_service.dart';
import 'package:otomatiksclub/config/app_config.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/utils/user_auth_data.dart';
import 'package:otomatiksclub/utils/utils.dart';
import 'dart:developer' as developer;

import '../api_client.dart'; // Import your custom API client

class ApiBlogService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> createBlog(
      File? imageFile,
      Map<String, dynamic> formData,
      bool isVideoType,
      String? fileId) async {
    try {
      // Fetch user authentication data
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      String clubId = "";
      Map<String, dynamic>? club = await getValue(AppConstants.clubKey);
      clubId = club?['id'];
      // Prepare the form data
      formData['userId'] = userId;
      formData['clubId'] = clubId;
      formData['action'] = 'Blog';

      http.Response? imageResponse;
      if (imageFile != null) {
        // Upload the image and await the response
        imageResponse =
            await ApiImageService.uploadImage('Blog', imageFile, isVideoType, fileId, userId!);

        // Check if the image upload was successful
        if (imageResponse.statusCode != 200) {
          return {
            'statusCode': imageResponse.statusCode,
            'body': imageResponse.body
          };
        }
      }
       if (imageResponse != null) {
        formData['blogUrl'] = imageResponse.body;
      }
      const url = '${AppConfig.apiUrl}/blogs';
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
      developer.log('create blog error: $e');
      return {'statusCode': 500, 'body': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> getBlogs(
      int page, int size) async {
    try {
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      String clubId = "";
      Map<String, dynamic>? club = await getValue(AppConstants.clubKey);
      clubId = club?['id'];
      final url =
          '${AppConfig.apiUrl}/blogs?userId=$userId&clubId=$clubId&page=$page&size=$size';
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
      developer.log('blog error: $e');
      return {'statusCode': 500, 'body': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> deleteBlog(String blogId) async {
    try {
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      final url = '${AppConfig.apiUrl}/blogs/$blogId?userId=$userId';
      final response = await _apiClient.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      return {'statusCode': response.statusCode, 'body': response.body};
    } catch (e) {
      // Handle errors
      developer.log('blog error: $e');
      return {'statusCode': 500, 'body': e.toString()};
    }
  }
}
