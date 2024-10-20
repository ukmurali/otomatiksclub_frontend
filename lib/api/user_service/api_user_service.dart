import 'dart:convert';

import 'package:stem_club/config/config.dart';
import 'package:stem_club/constants.dart';
import 'package:stem_club/utils/user_auth_data.dart';
import 'package:stem_club/utils/utils.dart';
import 'dart:developer' as developer;

import '../api_client.dart'; // Import your custom API client

class ApiUserService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    try {
      final sendOtpUrl = '${Config.apiUrl}/send-otp?mobileNumber=$mobileNumber';
      final response = await _apiClient.post(
        sendOtpUrl,
        headers: {'Content-Type': 'application/json'},
      );
      return {'statusCode': response.statusCode, 'body': response.body};
    } catch (e) {
      // Handle errors
      developer.log('Send otp error: $e');
      return {'statusCode': 500, 'body': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
      String mobileNumber, String otp) async {
    try {
      final sendOtpUrl =
          '${Config.apiUrl}/verify-otp?mobileNumber=$mobileNumber&otp=$otp';
      final response = await _apiClient.post(
        sendOtpUrl,
        headers: {'Content-Type': 'application/json'},
      );
      return {'statusCode': response.statusCode, 'body': response.body};
    } catch (e) {
      // Handle errors
      developer.log('verify otp error: $e');
      return {'statusCode': 500, 'body': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> checkUserExists(
      String mobileNumber) async {
    try {
      final url =
          '${Config.apiUrl}/users/verify-mobile?mobileNumber=$mobileNumber';
      final response = await _apiClient.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      return {'statusCode': response.statusCode, 'body': response.body};
    } catch (e) {
      // Handle errors
      developer.log('verify otp error: $e');
      return {'statusCode': 500, 'body': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createUser(
      Map<String, dynamic> formData) async {
    try {
      const createUser = '${Config.apiUrl}/users';
      final response = await _apiClient.post(
        createUser,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      );
      return {'statusCode': response.statusCode, 'body': response.body};
    } catch (e) {
      // Handle errors
      developer.log('user error: $e');
      return {'statusCode': 500, 'body': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateUser(
      Map<String, dynamic> formData) async {
    try {
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      final updateUser = '${Config.apiUrl}/users/$userId';
      final response = await _apiClient.patch(
        updateUser,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(formData),
      );
      return {'statusCode': response.statusCode, 'body': response.body};
    } catch (e) {
      // Handle errors
      developer.log('update user error: $e');
      return {'statusCode': 500, 'body': e.toString()};
    }
  }
}
