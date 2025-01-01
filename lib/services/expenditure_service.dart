import 'package:uniko/services/core/toast_service.dart';

import '../models/expenditure_fund.dart';
import 'core/api_service.dart';
import 'dart:convert';

class ExpenditureService {
  static final ExpenditureService _instance = ExpenditureService._internal();
  factory ExpenditureService() => _instance;
  ExpenditureService._internal();

  Future<ExpenditureFundResponse> getFunds() async {
    try {
      final response = await ApiService.call('/expenditure-funds');

      if (response.statusCode == 200) {
        return ExpenditureFundResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load funds: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load funds: $e');
    }
  }

  Future<CreateFundResponse> createFund({
    required String name,
    required String currency,
    String? description,
  }) async {
    try {
      final response = await ApiService.call(
        '/expenditure-funds',
        method: 'POST',
        body: {
          'name': name,
          'currency': currency,
          if (description != null) 'description': description,
        },
      );

      if (response.statusCode == 201) {
        ToastService.showSuccess('Tạo quỹ thành công');
        return CreateFundResponse.fromJson(jsonDecode(response.body));
      } else {
        ToastService.showError('Tạo quỹ thất bại - Vui lòng thử lại');
        throw Exception('Failed to create fund: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create fund: $e');
    }
  }
}
