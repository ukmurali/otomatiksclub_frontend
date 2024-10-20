import 'dart:convert';

import 'package:stem_club/config/config.dart';
import 'package:stem_club/utils/user_auth_data.dart';
import 'dart:developer' as developer;

import '../api_client.dart'; // Import your custom API client

class ApiPostService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> createPost(
      Map<String, dynamic> formData) async {
    try {
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      formData['userId'] = userId;
      const url = '${Config.apiUrl}/posts';
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
}
