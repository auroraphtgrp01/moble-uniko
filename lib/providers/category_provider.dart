import 'package:flutter/foundation.dart' hide Category;
import 'package:uniko/models/category.dart';
import 'package:uniko/services/category_service.dart';
import 'package:uniko/services/core/logger_service.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  List<Category> _incomeCategories = [];
  List<Category> _expenseCategories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  List<Category> get incomeCategories => _incomeCategories;
  List<Category> get expenseCategories => _expenseCategories;
  bool get isLoading => _isLoading;

  List<Category> getCategoriesByType(String type) {
    return _categories.where((cat) => cat.type == type).toList();
  }

  Future<List<Category>> getCustomCategory(String fundId) async {
    await this.fetchCategories(fundId);
    final categoriesCustom =
        _categories.where((cat) => cat.trackerType == 'CUSTOM').toList();
    print('categoriesCustom: ${categoriesCustom.length}');
    return categoriesCustom;
  }

  Future<void> fetchCategories(String fundId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await CategoryService().getCategories(fundId);
      _categories = response.data;

      _incomeCategories =
          _categories.where((cat) => cat.type == 'INCOMING').toList();

      _expenseCategories =
          _categories.where((cat) => cat.type == 'EXPENSE').toList();
    } catch (e) {
      LoggerService.error('Failed to fetch categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    String? description,
    required String fundId,
    String? type,
  }) async {
    try {
      await CategoryService().updateCategory(
        id: id,
        name: name,
        description: description,
        type: type,
        onSuccess: () async {
          // Refresh categories list after successful update
          await fetchCategories(fundId);
        },
      );
    } catch (e) {
      LoggerService.error('Failed to update category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory({
    required String id,
    required String fundId,
  }) async {
    try {
      await CategoryService().deleteCategory(
        id: id,
        onSuccess: () async {
          // Refresh categories list after successful deletion
          await fetchCategories(fundId);
        },
      );
    } catch (e) {
      LoggerService.error('Failed to delete category: $e');
      rethrow;
    }
  }
}
