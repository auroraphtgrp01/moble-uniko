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
}
