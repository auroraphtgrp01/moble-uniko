import 'package:flutter/foundation.dart';
import 'package:uniko/models/statistics.dart';
import 'package:uniko/services/statistics_service.dart';
import 'package:uniko/services/core/logger_service.dart';

class StatisticsProvider with ChangeNotifier {
  Statistics? _statistics;
  bool _isLoading = false;
  final _statisticsService = StatisticsService();

  Statistics? get statistics => _statistics;
  bool get isLoading => _isLoading;

  Future<void> fetchStatistics(
      String fundId, DateTime startDay, DateTime endDay) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await _statisticsService.getStatistics(fundId, startDay, endDay);
      _statistics = response;
    } catch (e) {
      LoggerService.error('Failed to fetch statistics: $e');
      _statistics = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
