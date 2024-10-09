import 'dart:convert';

import 'package:stem_club/config/config.dart';
import 'dart:developer' as developer;

import '../api_client.dart'; // Import your custom API client

class ApiUserService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Object> sendOtp(String mobileNumber) async {
    try {
      final sendOtpUrl = '${Config.apiUrl}/send-otp?mobileNumber=$mobileNumber';
      final response = await _apiClient.post(
        sendOtpUrl,
        headers: {'Content-Type': 'application/json'},
      );
      return response.body;
    } catch (e) {
      // Handle errors
      developer.log('Send otp error: $e');
      return false;
    }
  }
}
