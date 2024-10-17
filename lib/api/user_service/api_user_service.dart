import 'dart:convert';

import 'package:stem_club/config/config.dart';
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
      developer.log('verify otp error: $e');
      return {'statusCode': 500, 'body': e.toString()};
    }
  }
} 
