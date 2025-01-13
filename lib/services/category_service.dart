import 'dart:convert';
import 'package:uniko/config/app_config.dart';
import 'package:uniko/services/core/api_service.dart';
import 'package:uniko/models/category.dart';
import 'package:uniko/services/core/logger_service.dart';

class CategoryService {
  Future<CategoryResponse> getCategories(String fundId) async {
    try {
      final response = await ApiService.call(
        '/tracker-transaction-types/all/$fundId',
      );

      LoggerService.info('GET_CATEGORIES Response: ${response.body}');

      if (response.statusCode == 200) {
        return CategoryResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get categories: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error getting categories: $e');
      throw Exception('Failed to get categories: $e');
    }
  }
} 