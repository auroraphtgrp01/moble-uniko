import 'package:uniko/main.dart';
import 'package:uniko/services/core/logger_service.dart';
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
      LoggerService.debug('response XXX: ${response.body}');
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        LoggerService.debug('Decoded response: $decodedResponse');
        
        if (decodedResponse == null) {
          throw Exception('Response body is null');
        }
        
        if (decodedResponse['data'] == null) {
          return ExpenditureFundResponse(data: [], pagination: decodedResponse['pagination'] ?? {});
        }
        
        final List<dynamic> dataList = decodedResponse['data'] as List<dynamic>;
        final funds = dataList.map((item) {
          if (item == null) return null;
          try {
            return ExpenditureFund.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            LoggerService.debug('Error parsing fund: $e');
            return null;
          }
        }).whereType<ExpenditureFund>().toList();
        
        return ExpenditureFundResponse(
          data: funds,
          pagination: decodedResponse['pagination'] ?? {},
        );
      } else {
        throw Exception('Failed to load funds: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.debug('Error in getFunds: $e');
      rethrow;
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

  Future<void> updateFund({
    required String id,
    required String name,
    String? status,
    required String description,
  }) async {
    try {
      final response = await ApiService.call(
        '/expenditure-funds/$id',
        method: 'PATCH',
        body: {
          'id': id,
          'name': name,
          'status': status,
          'description': description,
        },
      );

      LoggerService.debug('response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        LoggerService.debug(
            'Fund updated successfully: ${responseData['data']}');
        ToastService.showSuccess('Cập nhật quỹ thành công');
      } else {
        ToastService.showError('Cập nhật quỹ thất bại');
        throw Exception('Failed to update fund: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update fund: $e');
    }
  }

  Future<void> deleteFund(String id) async {
    try {
      final response = await ApiService.call(
        '/expenditure-funds/remove-one/$id',
        method: 'DELETE',
      );

      LoggerService.debug('response delete fund: ${response.body}');

      if (response.statusCode == 200) {
        LoggerService.debug('Fund deleted successfully');
        ToastService.showSuccess('Xóa quỹ thành công');
      } else {
        ToastService.showError('Xóa quỹ thất bại');
        throw Exception('Failed to delete fund: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete fund: $e');
    }
  }

  Future<void> inviteParticipant({
    required String fundId,
    required List<String> emails,
  }) async {
    try {
      final response = await ApiService.call(
        '/participants/invite-participant',
        method: 'POST',
        body: {
          'fundId': fundId,
          'userInfoValues': emails,
        },
      );

      LoggerService.debug('response invite participant: ${response.body}');

      if (response.statusCode == 201) {
        LoggerService.debug('Invited participants successfully');
        ToastService.showSuccess('Đã gửi lời mời thành công');
      } else {
        ToastService.showError('Gửi lời mời thất bại');
        throw Exception(
            'Failed to invite participants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to invite participants: $e');
    }
  }
}

class ExpenditureFundResponse {
  final List<ExpenditureFund> data;
  final Map<String, dynamic> pagination;
  
  ExpenditureFundResponse({
    required this.data,
    required this.pagination,
  });
  
  factory ExpenditureFundResponse.fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic> dataList = json['data'] as List<dynamic>;
      final funds = dataList.map((item) {
        if (item == null) return null;
        try {
          return ExpenditureFund.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          LoggerService.debug('Error parsing fund in response: $e');
          return null;
        }
      }).whereType<ExpenditureFund>().toList();

      return ExpenditureFundResponse(
        data: funds,
        pagination: json['pagination'] as Map<String, dynamic>? ?? {},
      );
    } catch (e) {
      LoggerService.debug('Error in ExpenditureFundResponse.fromJson: $e');
      return ExpenditureFundResponse(data: [], pagination: {});
    }
  }
}
