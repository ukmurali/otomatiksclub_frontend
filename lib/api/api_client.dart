import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity/connectivity.dart';

class ApiClient {
  final http.Client _client = http.Client();
  final Duration _timeoutDuration = const Duration(seconds: 30);

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception("No internet connection available");
    }
  }

  Future<http.Response> get(String url,
      {Map<String, String>? headers,
      Map<String, String>? queryParameters}) async {
    await _checkConnectivity(); // Reuse connectivity check

    try {
      final response = await _client
          .get(
            Uri.parse(url).replace(queryParameters: queryParameters),
            headers: headers,
          )
          .timeout(_timeoutDuration);

      return response;
    } on TimeoutException catch (_) {
      developer.log('GET request timeout');
      throw Exception('Request timed out. Please try again later.');
    } on http.ClientException catch (e) {
      developer.log('Network error: $e');
      throw Exception(
          'Network error occurred. Check your connection and try again.');
    } catch (e) {
      developer.log('Unexpected error: $e');
      throw Exception(
          'An unexpected error occurred. Please try again after some time.');
    }
  }

  Future<http.Response> post(String url,
      {Map<String, String>? headers, dynamic body}) async {
    await _checkConnectivity(); // Reuse connectivity check

    try {
      final apiUrl = Uri.parse(url);
      final response = await http
          .post(
            apiUrl,
            headers: headers,
            body: body,
          )
          .timeout(_timeoutDuration);
      return response;
    } on TimeoutException catch (_) {
      developer.log('POST request timeout');
      throw Exception('Request timed out. Please try again later.');
    } on http.ClientException catch (e) {
      developer.log('Network error: $e');
      throw Exception(
          'Network error occurred. Check your connection and try again.');
    } catch (e) {
      developer.log('Unexpected error: $e');
      throw Exception(
          'An unexpected error occurred. Please try again after some time.');
    }
  }

  Future<http.Response> patch(String url,
      {Map<String, String>? headers, dynamic body}) async {
    await _checkConnectivity(); // Reuse connectivity check

    try {
      final apiUrl = Uri.parse(url);
      final response = await http
          .patch(
            apiUrl,
            headers: headers,
            body: body,
          )
          .timeout(_timeoutDuration);
      return response;
    } on TimeoutException catch (_) {
      developer.log('PATCH request timeout');
      throw Exception('Request timed out. Please try again later.');
    } on http.ClientException catch (e) {
      developer.log('Network error: $e');
      throw Exception(
          'Network error occurred. Check your connection and try again.');
    } catch (e) {
      developer.log('Unexpected error: $e');
      throw Exception(
          'An unexpected error occurred. Please try again after some time.');
    }
  }

  Future<http.Response> delete(String url,
      {Map<String, String>? headers,
      Map<String, String>? queryParameters}) async {
    await _checkConnectivity(); // Reuse connectivity check

    try {
      final response = await _client
          .delete(
            Uri.parse(url).replace(queryParameters: queryParameters),
            headers: headers,
          )
          .timeout(_timeoutDuration);

      return response;
    } on TimeoutException catch (_) {
      developer.log('DELETE request timeout');
      throw Exception('Request timed out. Please try again later.');
    } on http.ClientException catch (e) {
      developer.log('Network error: $e');
      throw Exception(
          'Network error occurred. Check your connection and try again.');
    } catch (e) {
      developer.log('Unexpected error: $e');
      throw Exception(
          'An unexpected error occurred. Please try again after some time.');
    }
  }
}
