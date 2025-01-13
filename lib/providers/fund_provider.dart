import 'package:flutter/foundation.dart';
import 'package:uniko/models/expenditure_fund.dart';
import 'package:uniko/services/core/logger_service.dart';
import 'package:uniko/services/expenditure_service.dart';

class FundProvider with ChangeNotifier {
  String _selectedFund = 'Tất cả';
  List<ExpenditureFund> _funds = [];
  bool _isLoading = false;

  String get selectedFund => _selectedFund;
  List<ExpenditureFund> get funds => _funds;
  bool get isLoading => _isLoading;

  Future<void> initializeFunds() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ExpenditureService().getFunds();
      _funds = response.data;
      // Nếu có quỹ, set quỹ đầu tiên làm mặc định
      if (_funds.isNotEmpty) {
        _selectedFund = _funds[0].name;
      }
    } catch (e) {
      LoggerService.error('Failed to initialize funds: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedFund(String fund) {
    _selectedFund = fund;
    notifyListeners();
  }
}
