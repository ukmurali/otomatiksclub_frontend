import 'package:otomatiksclub/config/app_config.dart';
import 'dart:developer' as developer;

import '../api_client.dart'; // Import your custom API client

class ApiPricingPlanService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>?> fetchPricingPlans() async {
    try {
      const url = '${AppConfig.apiUrl}/pricing-plans';
      final response = await _apiClient.get(
        url,
        headers: {
          'Content-Type': 'application/json'
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
