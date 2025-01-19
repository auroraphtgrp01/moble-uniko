import 'package:uniko/services/core/logger_service.dart';

class Statistics {
  final List<StatItem> incomingTransactionTypeStats;
  final List<StatItem> expenseTransactionTypeStats;
  final List<StatItem> incomingTransactionAccountTypeStats;
  final List<StatItem> expenseTransactionAccountTypeStats;
  final TotalStats total;
  final IncomeExpenseStats income;
  final IncomeExpenseStats expense;
  final List<CashFlowItem> cashFlowAnalysis;
  final List<UnclassifiedTransaction> unclassifiedTransactions;

  Statistics({
    required this.incomingTransactionTypeStats,
    required this.expenseTransactionTypeStats,
    required this.incomingTransactionAccountTypeStats,
    required this.expenseTransactionAccountTypeStats,
    required this.total,
    required this.income,
    required this.expense,
    required this.cashFlowAnalysis,
    required this.unclassifiedTransactions,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      incomingTransactionTypeStats:
          (json['incomingTransactionTypeStats'] as List)
              .map((item) => StatItem.fromJson(item))
              .toList(),
      expenseTransactionTypeStats: (json['expenseTransactionTypeStats'] as List)
          .map((item) => StatItem.fromJson(item))
          .toList(),
      incomingTransactionAccountTypeStats:
          (json['incomingTransactionAccountTypeStats'] as List)
              .map((item) => StatItem.fromJson(item))
              .toList(),
      expenseTransactionAccountTypeStats:
          (json['expenseTransactionAccountTypeStats'] as List)
              .map((item) => StatItem.fromJson(item))
              .toList(),
      total: TotalStats.fromJson(json['total']),
      income: IncomeExpenseStats.fromJson(json['income']),
      expense: IncomeExpenseStats.fromJson(json['expense']),
      cashFlowAnalysis: (json['cashFlowAnalysis'] as List)
          .map((item) => CashFlowItem.fromJson(item))
          .toList(),
      unclassifiedTransactions: (json['unclassifiedTransactions'] as List)
          .map((item) => UnclassifiedTransaction.fromJson(item))
          .toList(),
    );
  }
}

class StatItem {
  final String name;
  final int value;

  StatItem({required this.name, required this.value});

  factory StatItem.fromJson(Map<String, dynamic> json) {
    return StatItem(
      name: json['name'],
      value: json['value'],
    );
  }
}

class TotalStats {
  final int totalBalance;
  final String rate;

  TotalStats({required this.totalBalance, required this.rate});

  factory TotalStats.fromJson(Map<String, dynamic> json) {
    return TotalStats(
      totalBalance: json['totalBalance'],
      rate: json['rate'],
    );
  }
}

class IncomeExpenseStats {
  final int totalToday;
  final String rate;

  IncomeExpenseStats({required this.totalToday, required this.rate});

  factory IncomeExpenseStats.fromJson(Map<String, dynamic> json) {
    return IncomeExpenseStats(
      totalToday: json['totalIncomeToday'] ?? json['totalExpenseToday'],
      rate: json['rate'],
    );
  }
}

class CashFlowItem {
  final String date;
  final int incoming;
  final int outgoing;

  CashFlowItem({
    required this.date,
    required this.incoming,
    required this.outgoing,
  });

  factory CashFlowItem.fromJson(Map<String, dynamic> json) {
    return CashFlowItem(
      date: json['date'],
      incoming: json['incoming'],
      outgoing: json['outgoing'],
    );
  }
}

class UnclassifiedTransaction {
  final String id;
  final String direction;
  final int amount;
  final String? toAccountNo;
  final String? toAccountName;
  final String? toBankName;
  final String currency;
  final String description;
  final DateTime transactionDateTime;
  final AccountSource accountSource;
  final OfAccount ofAccount;

  UnclassifiedTransaction({
    required this.id,
    required this.direction,
    required this.amount,
    this.toAccountNo,
    this.toAccountName,
    this.toBankName,
    required this.currency,
    required this.description,
    required this.transactionDateTime,
    required this.accountSource,
    required this.ofAccount,
  });

  factory UnclassifiedTransaction.fromJson(Map<String, dynamic> json) {
    try {
      return UnclassifiedTransaction(
        id: json['id']?.toString() ?? '',
        direction: json['direction']?.toString() ?? '',
        amount: json['amount'] ?? 0,
        toAccountNo: json['toAccountNo']?.toString(),
        toAccountName: json['toAccountName']?.toString(),
        toBankName: json['toBankName']?.toString(),
        currency: json['currency']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        transactionDateTime: DateTime.parse(
            json['transactionDateTime']?.toString() ?? DateTime.now().toIso8601String()),
        accountSource: AccountSource.fromJson(json['accountSource'] ?? {}),
        ofAccount: OfAccount.fromJson(json['ofAccount'] ?? {}),
      );
    } catch (e) {
      LoggerService.error('Error parsing UnclassifiedTransaction: $e');
      rethrow;
    }
  }
}

class AccountSource {
  final String name;
  final AccountBank accountBank;

  AccountSource({
    required this.name,
    required this.accountBank,
  });

  factory AccountSource.fromJson(Map<String, dynamic> json) {
    return AccountSource(
      name: json['name']?.toString() ?? '',
      accountBank: AccountBank.fromJson(json['accountBank'] ?? {}),
    );
  }
}

class AccountBank {
  final List<BankAccount> accounts;

  AccountBank({required this.accounts});

  factory AccountBank.fromJson(Map<String, dynamic> json) {
    return AccountBank(
      accounts: ((json['accounts'] as List?) ?? [])
          .map((item) => BankAccount.fromJson(item ?? {}))
          .toList(),
    );
  }
}

class BankAccount {
  final String accountNo;

  BankAccount({required this.accountNo});

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      accountNo: json['accountNo']?.toString() ?? '',
    );
  }
}

class OfAccount {
  final String id;
  final String accountNo;
  final String accountBankId;

  OfAccount({
    required this.id,
    required this.accountNo,
    required this.accountBankId,
  });

  factory OfAccount.fromJson(Map<String, dynamic> json) {
    return OfAccount(
      id: json['id']?.toString() ?? '',
      accountNo: json['accountNo']?.toString() ?? '',
      accountBankId: json['accountBankId']?.toString() ?? '',
    );
  }
}
