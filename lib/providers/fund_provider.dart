import 'package:flutter/foundation.dart';
import 'package:uniko/models/expenditure_fund.dart';
import 'package:uniko/services/core/logger_service.dart';
import 'package:uniko/services/expenditure_service.dart';
import 'package:uniko/providers/account_source_provider.dart';
import 'package:provider/provider.dart';
import 'package:uniko/main.dart';
import 'package:uniko/providers/category_provider.dart';
import 'package:uniko/providers/statistics_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FundProvider with ChangeNotifier {
  static const String _selectedFundKey = 'selected_fund';
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
      final prefs = await SharedPreferences.getInstance();
      final savedFund = prefs.getString(_selectedFundKey);
      
      final response = await ExpenditureService().getFunds();
      _funds = response.data;
      
      if (_funds.isNotEmpty) {
        if (savedFund != null && _funds.any((fund) => fund.name == savedFund)) {
          _selectedFund = savedFund;
        } else {
          _selectedFund = _funds[0].name;
        }
        
        final fundId = selectedFundId;
        if (fundId != null) {
          final context = navigatorKey.currentContext!;
          await Future.wait([
            Provider.of<AccountSourceProvider>(context, listen: false)
                .fetchAccountSources(fundId),
            Provider.of<CategoryProvider>(context, listen: false)
                .fetchCategories(fundId),
            Provider.of<StatisticsProvider>(context, listen: false)
                .fetchStatistics(
              fundId,
              DateTime.now().subtract(const Duration(days: 30)),
              DateTime.now(),
            ),
          ]);
        }
      }
    } catch (e) {
      LoggerService.error('Failed to initialize funds: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedFund(String fundName) async {
    _selectedFund = fundName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedFundKey, fundName);
    
    final fundId = selectedFundId;
    if (fundId != null) {
      final context = navigatorKey.currentContext!;

      Provider.of<AccountSourceProvider>(context, listen: false)
          .fetchAccountSources(fundId);
      Provider.of<CategoryProvider>(context, listen: false)
          .fetchCategories(fundId);
      Provider.of<StatisticsProvider>(context, listen: false).fetchStatistics(
        fundId,
        DateTime.now().subtract(const Duration(days: 30)),
        DateTime.now(),
      );
    }
    notifyListeners();
  }

  Future<void> refreshFunds() async {
    try {
      LoggerService.info('Refreshing funds');
      final response = await ExpenditureService().getFunds();
      _funds = response.data;

      if (_funds.isNotEmpty &&
          (_selectedFund.isEmpty ||
              !_funds.any((fund) => fund.name == _selectedFund))) {
        _selectedFund = _funds[0].name;

        final context = navigatorKey.currentContext!;
        await Future.wait([
          Provider.of<AccountSourceProvider>(context, listen: false)
              .fetchAccountSources(_funds[0].id),
          Provider.of<CategoryProvider>(context, listen: false)
              .fetchCategories(_funds[0].id),
          Provider.of<StatisticsProvider>(context, listen: false)
              .fetchStatistics(
            _funds[0].id,
            DateTime.now().subtract(const Duration(days: 30)),
            DateTime.now(),
          ),
        ]);
      } else if (_selectedFund.isNotEmpty) {
        final fundId = selectedFundId;
        if (fundId != null) {
          final context = navigatorKey.currentContext!;
          await Future.wait([
            Provider.of<AccountSourceProvider>(context, listen: false)
                .fetchAccountSources(fundId),
            Provider.of<CategoryProvider>(context, listen: false)
                .fetchCategories(fundId),
            Provider.of<StatisticsProvider>(context, listen: false)
                .fetchStatistics(
              fundId,
              DateTime.now().subtract(const Duration(days: 30)),
              DateTime.now(),
            ),
          ]);
        }
      }

      notifyListeners();
    } catch (e) {
      LoggerService.error('Failed to refresh funds: $e');
    }
  }
}
