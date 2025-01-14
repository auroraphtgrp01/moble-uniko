import 'dart:convert';
import 'package:uniko/config/app_config.dart';
import 'package:uniko/services/core/api_service.dart';
import 'package:uniko/services/core/logger_service.dart';
import '../models/tracker_transaction.dart';
import '../models/tracker_transaction_detail.dart';

class TrackerTransactionService {
  Future<TrackerTransactionResponse> getAdvancedTrackerTransactions(
    String fundId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiService.call(
        '/tracker-transactions/query-advanced/$fundId?page=$page&limit=$limit',
      );

      LoggerService.info('GET_TRACKER_TRANSACTIONS Response: ${response.body}');

      if (response.statusCode == 200) {
        return TrackerTransactionResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Failed to get tracker transactions: ${response.statusCode}',
        );
      }
    } catch (e) {
      LoggerService.error('Error getting tracker transactions: $e');
      throw Exception('Failed to get tracker transactions: $e');
    }
  }

  Future<TrackerTransactionDetail> getTransactionById(String id) async {
    try {
      final response = await ApiService.call(
        AppConfig.getTransactionByIdEndpoint(id),
        method: 'GET',
      );

      LoggerService.info('GET_TRANSACTION_BY_ID Response: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return TrackerTransactionDetail.fromJson(responseData['data']);
      }

      throw Exception(
          responseData['message'] ?? 'Failed to get transaction details');
    } catch (e) {
      throw Exception('Error getting transaction details: $e');
    }
  }
}

// Models
class TrackerTransactionResponse {
  final Pagination pagination;
  final List<TrackerTransaction> data;
  final int statusCode;

  TrackerTransactionResponse({
    required this.pagination,
    required this.data,
    required this.statusCode,
  });

  factory TrackerTransactionResponse.fromJson(Map<String, dynamic> json) {
    return TrackerTransactionResponse(
      pagination: Pagination.fromJson(json['pagination']),
      data: (json['data'] as List)
          .map((item) => TrackerTransaction.fromJson(item))
          .toList(),
      statusCode: json['statusCode'],
    );
  }
}

class Pagination {
  final int totalPage;
  final int currentPage;
  final int limit;
  final int skip;

  Pagination({
    required this.totalPage,
    required this.currentPage,
    required this.limit,
    required this.skip,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalPage: json['totalPage'],
      currentPage: json['currentPage'],
      limit: json['limit'],
      skip: json['skip'],
    );
  }
}
