import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:otomatiksclub/api/image_service/api_image_service.dart';
import 'package:otomatiksclub/config/app_config.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/model/user.dart';
import 'package:otomatiksclub/utils/user_auth_data.dart';
import 'package:otomatiksclub/utils/utils.dart';
import 'dart:developer' as developer;

import '../api_client.dart'; // Import your custom API client

class ApiPostService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> createPost(
      File? imageFile,
      Map<String, dynamic> formData,
      bool isVideoType,
      String? fileId,
      User? selectedUser) async {
    try {
      await ApiClient.checkConnectivity();
      // Fetch user authentication data
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      String clubId = "";
      Map<String, dynamic>? club = await getValue(AppConstants.clubKey);
      clubId = club?['id'];
      // Prepare the form data
      String? userIdValue = selectedUser == null ? userId : selectedUser.id;
      formData['userId'] = userIdValue;
      formData['postedBy'] = userId;
      formData['clubId'] = clubId;
      //formData['action'] = 'Post';

      http.Response? imageResponse;
      if (imageFile != null) {
        // Upload the image and await the response
        imageResponse =
            await ApiImageService.uploadImage('Post', imageFile, isVideoType, fileId, userIdValue!);

        // Check if the image upload was successful
        if (imageResponse.statusCode != 200) {
          return {
            'statusCode': imageResponse.statusCode,
            'body': imageResponse.body
          };
        }
      }
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

  static Future<Map<String, dynamic>?> getAllPost(
      bool isAllPost, int page, int size,
      {String postType = AppConstants.image,
      String postStatus = 'APPROVED',
      bool allPostMediaType = true}) async {
    try {
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      String clubId = "";
      Map<String, dynamic>? club = await getValue(AppConstants.clubKey);
      clubId = club?['id'];
      final url =
          '${AppConfig.apiUrl}/posts?userId=$userId&clubId=$clubId&isAllPost=$isAllPost&postStatus=$postStatus&allPostMediaType=$allPostMediaType&postType=$postType&page=$page&size=$size';
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
      developer.log('post error: $e');
      return {'statusCode': 500, 'body': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> getPost(String postId) async {
    try {
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      final url = '${AppConfig.apiUrl}/posts/$postId?userId=$userId';
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

  static Future<Map<String, dynamic>?> deletePost(String postId, String fileId) async {
    try {
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      final url = '${AppConfig.apiUrl}/posts/$postId?userId=$userId&fileId=$fileId';
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
      developer.log('post error: $e');
      return {'statusCode': 500, 'body': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> approveOrRejectPost(
      String action, String postId, String reason) async {
    try {
      // Fetch user authentication data
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      String clubId = "";
      Map<String, dynamic>? club = await getValue(AppConstants.clubKey);
      clubId = club?['id'];
      Map<String, String> formData = {};
      // Prepare the form data
      formData['userId'] = userId!;
      formData['clubId'] = clubId;
      formData['rejectedReason'] = reason;
      final url = '${AppConfig.apiUrl}/posts/$postId/$action';
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

  static Future<Map<String, dynamic>?> fetchPostStatusCount() async {
    try {
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      String clubId = "";
      Map<String, dynamic>? club = await getValue(AppConstants.clubKey);
      clubId = club?['id'];
      final url =
          '${AppConfig.apiUrl}/posts/status-count/$userId?clubId=$clubId';
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
