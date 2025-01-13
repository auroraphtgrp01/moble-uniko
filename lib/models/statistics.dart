class Statistics {
  final List<StatItem> incomingTransactionTypeStats;
  final List<StatItem> expenseTransactionTypeStats;
  final List<StatItem> incomingTransactionAccountTypeStats;
  final List<StatItem> expenseTransactionAccountTypeStats;
  final TotalStats total;
  final IncomeExpenseStats income;
  final IncomeExpenseStats expense;

  Statistics({
    required this.incomingTransactionTypeStats,
    required this.expenseTransactionTypeStats,
    required this.incomingTransactionAccountTypeStats,
    required this.expenseTransactionAccountTypeStats,
    required this.total,
    required this.income,
    required this.expense,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      incomingTransactionTypeStats: (json['incomingTransactionTypeStats'] as List)
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