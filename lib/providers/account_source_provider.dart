import 'package:flutter/foundation.dart';
import 'package:uniko/models/account_source.dart';
import 'package:uniko/services/account_source_service.dart';
import 'package:uniko/services/core/logger_service.dart';

class AccountSourceProvider with ChangeNotifier {
  List<AccountSource> _accountSources = [];
  bool _isLoading = false;

  List<AccountSource> get accountSources => _accountSources;
  bool get isLoading => _isLoading;

  Future<void> fetchAccountSources(String fundId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await AccountSourceService().getAdvancedAccountSources(fundId);
      _accountSources = response.data;
    } catch (e) {
      LoggerService.error('Failed to fetch account sources: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
