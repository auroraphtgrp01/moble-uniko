import 'dart:convert';
import 'package:uniko/models/statistics.dart';
import 'package:uniko/services/core/api_service.dart';
import 'package:uniko/services/core/logger_service.dart';

class StatisticsService {
  Future<Statistics> getStatistics(
      String fundId, DateTime startDay, DateTime endDay) async {
    final response = await ApiService.call(
      '/tracker-transactions/statistics/$fundId',
      method: 'GET',
      queryParameters: {
        'startDay': startDay.toIso8601String().split('T')[0],
        'endDay': endDay.toIso8601String().split('T')[0],
      },
    );

    print(response);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      LoggerService.api('/tracker-transactions/statistics/$fundId', jsonData);
      return Statistics.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to load statistics');
    }
  }
}
