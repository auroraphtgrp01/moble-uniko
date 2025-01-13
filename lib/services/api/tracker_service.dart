import '../core/api_service.dart';
import '../core/logger_service.dart';
import 'dart:convert';

class TrackerService {
  static Future<Map<String, dynamic>> createTracker({
    required String trackerTypeId,
    required String reasonName,
    required String direction,
    required double amount,
    required String accountSourceId,
    required String fundId,
    String? description,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'trackerTypeId': trackerTypeId,
        'reasonName': reasonName,
        'direction': direction,
        'amount': amount,
        'accountSourceId': accountSourceId,
        'fundId': fundId,
      };

      // Thêm description nếu có
      if (description != null && description.isNotEmpty) {
        payload['description'] = description;
      }

      final response = await ApiService.call(
        '/tracker-transactions',
        method: 'POST',
        body: payload,
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create tracker: ${response.statusCode}');
      }

    } catch (e) {
      LoggerService.error('Create Tracker Error: $e');
      rethrow;
    }
  }
} 