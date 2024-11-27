import 'dart:convert';
import 'package:otomatiksclub/config/app_config.dart';
import 'package:otomatiksclub/utils/user_auth_data.dart';
import 'dart:developer' as developer;

import '../api_client.dart'; // Import your custom API client

class ApiPostCommentService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> createComment(Map<String, dynamic> formData) async {
    try {
      // Fetch user authentication data
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      formData['commentedBy'] = userId;
      const url = '${AppConfig.apiUrl}/comments';
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

  static Future<Map<String, dynamic>?> getComments(
      String postId, int page, int size) async {
    try {
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      final url =
          '${AppConfig.apiUrl}/comments?userId=$userId&postId=$postId&page=$page&size=$size';
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

  static Future<Map<String, dynamic>> removeFavorite(String postId) async {
    try {
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      final url =
          '${AppConfig.apiUrl}/favorites/remove?postId=$postId&userId=$userId';
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
      developer.log('verify otp error: $e');
      return {'statusCode': 500, 'body': e.toString()};
    }
  }
}
