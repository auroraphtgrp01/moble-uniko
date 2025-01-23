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

  Future<void> updateCategory({
    required String id,
    required String name,
    String? description,
    String? type,
    VoidCallback? onSuccess,
  }) async {
    try {
      LoggerService.info(
          'UPDATE_CATEGORY Request: id=$id, name=$name, description=$description');
      
      final response = await ApiService.call(
        '/tracker-transaction-types/$id',
        method: 'PATCH',
        body: {
          'name': name,
          'description': description,
          'type': type,
        },
      );

      LoggerService.info('UPDATE_CATEGORY Response: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update category: ${response.statusCode}');
      }

      ToastService.showSuccess('Cập nhật danh mục thành công!');
      onSuccess?.call();
    } catch (e) {
      LoggerService.error('Error updating category: $e');
      ToastService.showError('Lỗi khi cập nhật danh mục!');
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory({
    required String id,
    VoidCallback? onSuccess,
  }) async {
    try {
      LoggerService.info('DELETE_CATEGORY Request: id=$id');
      
      final response = await ApiService.call(
        '/tracker-transaction-types/$id',
        method: 'DELETE',
      );

      LoggerService.info('DELETE_CATEGORY Response: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete category: ${response.statusCode}');
      }

      ToastService.showSuccess('Xóa danh mục thành công!');
      onSuccess?.call();
    } catch (e) {
      LoggerService.error('Error deleting category: $e');
      ToastService.showError('Lỗi khi xóa danh mục!');
      throw Exception('Failed to delete category: $e');
    }
  }
}
