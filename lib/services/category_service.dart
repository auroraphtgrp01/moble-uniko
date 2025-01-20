import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uniko/config/app_config.dart';
import 'package:uniko/services/core/api_service.dart';
import 'package:uniko/models/category.dart';
import 'package:uniko/services/core/logger_service.dart';
import 'package:uniko/services/core/toast_service.dart';

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

  Future<void> createCategory({
    required String name,
    required String type,
    required String fundId,
    String? description,
    VoidCallback? onSuccess,
  }) async {
    try {
      LoggerService.info(
          'CREATE_CATEGORY Request: $name, $type, $fundId, $description');
      final response = await ApiService.call(
        '/tracker-transaction-types',
        method: 'POST',
        body: {
          'name': name,
          'type': type,
          'trackerType': 'CUSTOM',
          'fundId': fundId,
          'description': description,
        },
      );

      LoggerService.info('CREATE_CATEGORY Response: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to create category: ${response.statusCode}');
      }

      ToastService.showSuccess('Tạo danh mục thành công !');
      onSuccess?.call();
    } catch (e) {
      LoggerService.error('Error creating category: $e');
      ToastService.showError('Lỗi khi tạo danh mục mới !');
      throw Exception('Failed to create category: $e');
    }
  }
}
