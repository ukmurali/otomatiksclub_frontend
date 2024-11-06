import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:otomatiksclub/model/instagram_media.dart';

class InstagramService {
  final String baseUrl = "http://192.168.0.5:8080/api/instagram";

  Future<List<InstagramMedia>> fetchMedia() async {
    final response = await http.get(Uri.parse('$baseUrl/media'));

    if (response.statusCode == 200) {
      // Decode the response body as a list of dynamic JSON objects
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> list = jsonResponse['data'];
      // Map the list of JSON objects to a list of InstagramMedia objects
      return list.map((json) => InstagramMedia.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load media");
    }
  }
}


