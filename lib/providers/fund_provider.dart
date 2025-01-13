import 'package:flutter/foundation.dart';
import 'package:uniko/models/expenditure_fund.dart';
import 'package:uniko/services/core/logger_service.dart';
import 'package:uniko/services/expenditure_service.dart';
import 'package:uniko/providers/account_source_provider.dart';
import 'package:provider/provider.dart';
import 'package:uniko/main.dart';

class FundProvider with ChangeNotifier {
  String _selectedFund = '';
  List<ExpenditureFund> _funds = [];
  bool _isLoading = false;

  String get selectedFund => _selectedFund;
  List<ExpenditureFund> get funds => _funds;
  bool get isLoading => _isLoading;

  String? get selectedFundId => _funds.isEmpty
      ? null
      : _funds.firstWhere((fund) => fund.name == _selectedFund).id;

  Future<void> initializeFunds() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ExpenditureService().getFunds();
      _funds = response.data;
      if (_funds.isNotEmpty) {
        _selectedFund = _funds[0].name;
        // Fetch account sources for initial fund
        await Provider.of<AccountSourceProvider>(navigatorKey.currentContext!,
                listen: false)
            .fetchAccountSources(_funds[0].id);
      }
    } catch (e) {
      LoggerService.error('Failed to initialize funds: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedFund(String fundName) {
    _selectedFund = fundName;
    // Fetch account sources when fund changes
    final fundId = selectedFundId;
    if (fundId != null) {
      Provider.of<AccountSourceProvider>(navigatorKey.currentContext!,
              listen: false)
          .fetchAccountSources(fundId);
    }
    notifyListeners();
  }
}
