import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import 'storage_service.dart';

class ApiService {
  static final _dio = dio.Dio(dio.BaseOptions(
    baseUrl: AppConfig.apiUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

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
    try {
      final headers = await _getAuthenticatedHeaders();
      _dio.options.headers = headers;

      dio.Response dioResponse;
      switch (method) {
        case 'POST':
          dioResponse = await _dio.post(endpoint, data: body, queryParameters: queryParameters);
          break;
        case 'PUT':
          dioResponse = await _dio.put(endpoint, data: body, queryParameters: queryParameters);
          break;
        case 'DELETE':
          dioResponse = await _dio.delete(endpoint, queryParameters: queryParameters);
          break;
        case 'PATCH':
          dioResponse = await _dio.patch(endpoint, data: body, queryParameters: queryParameters);
          break;
        default:
          dioResponse = await _dio.get(endpoint, queryParameters: queryParameters);
          break;
      }

      // Convert Dio response to http.Response format
      return http.Response(
        jsonEncode(dioResponse.data),
        dioResponse.statusCode ?? 500,
        headers: {
          'content-type': 'application/json',
          ...dioResponse.headers.map.map((key, value) => MapEntry(key, value.join(','))),
        },
      );
    } on dio.DioException catch (e) {
      if (e.response != null) {
        return http.Response(
          jsonEncode(e.response?.data ?? {}),
          e.response?.statusCode ?? 500,
        );
      }
      throw Exception('API Call Error: ${e.message}');
    }
  }
}
