import 'package:flutter/foundation.dart' hide Category;
import 'package:uniko/models/category.dart';
import 'package:uniko/services/category_service.dart';
import 'package:uniko/services/core/logger_service.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  List<Category> getCategoriesByType(String type) {
    return _categories.where((category) => 
      category.type == type && category.trackerType == 'DEFAULT'
    ).toList();
  }

  Future<void> fetchCategories(String fundId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await CategoryService().getCategories(fundId);
      _categories = response.data;
    } catch (e) {
      LoggerService.error('Failed to fetch categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
