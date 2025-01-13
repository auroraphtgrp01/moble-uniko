import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import 'storage_service.dart';

class ApiService {
  static Future<Map<String, String>> _getAuthenticatedHeaders() async {
    final token = await StorageService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> call(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final headers = await _getAuthenticatedHeaders();
    final uri = Uri.parse('${AppConfig.apiUrl}$endpoint').replace(
      queryParameters:
          queryParameters?.map((key, value) => MapEntry(key, value.toString())),
    );

    try {
      switch (method) {
        case 'POST':
          return http.post(uri, headers: headers, body: json.encode(body));
        case 'PUT':
          return http.put(uri, headers: headers, body: json.encode(body));
        case 'DELETE':
          return http.delete(uri, headers: headers);
        case 'PATCH':
          return http.patch(uri, headers: headers, body: json.encode(body));
        default:
          return http.get(uri, headers: headers);
      }
    } catch (e) {
      throw Exception('API Call Error: $e');
    }
  }
}
