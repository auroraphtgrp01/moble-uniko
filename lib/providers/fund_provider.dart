import 'package:flutter/foundation.dart';

class FundProvider with ChangeNotifier {
  String _selectedFund = 'Tất cả';

  String get selectedFund => _selectedFund;

  void setSelectedFund(String fund) {
    _selectedFund = fund;
    notifyListeners();
  }
} 