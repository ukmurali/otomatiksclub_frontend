import 'dart:convert';

import 'package:otomatiksclub/config/app_config.dart';
import 'package:otomatiksclub/utils/user_auth_data.dart';
import 'dart:developer' as developer;

import '../api_client.dart'; // Import your custom API client

class ApiUserService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>?> getCountryCodes() async {
    try {
      const url = '${AppConfig.apiUrl}/country-codes';
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

  static Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    try {
      final sendOtpUrl = '${AppConfig.apiUrl}/send-otp?mobileNumber=$mobileNumber';
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
          '${AppConfig.apiUrl}/verify-otp?mobileNumber=$mobileNumber&otp=$otp';
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
          '${AppConfig.apiUrl}/users/verify-mobile?mobileNumber=$mobileNumber';
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

  static Future<Map<String, dynamic>?> searchUsers(String query) async {
    try {
      final url = '${AppConfig.apiUrl}/users/search?query=${Uri.encodeComponent(query)}';
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
      const createUser = '${AppConfig.apiUrl}/users';
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
      final updateUser = '${AppConfig.apiUrl}/users/$userId';
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

  static Future<Map<String, dynamic>> joinUser() async {
    try {
      UserAuthData userAuthData = await getUserIdAndAuthToken();
      String? authToken = userAuthData.authToken;
      String? userId = userAuthData.userId;
      final updateUser = '${AppConfig.apiUrl}/users/$userId/join';
      final response = await _apiClient.patch(
        updateUser,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      return {'statusCode': response.statusCode, 'body': response.body};
    } catch (e) {
      // Handle errors
      developer.log('update user error: $e');
      return {'statusCode': 500, 'body': e.toString()};
    }
  }
}
