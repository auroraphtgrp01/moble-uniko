import 'account_source.dart';

class Transaction {
  final String id;
  final String direction;
  final String? transactionId;
  final int amount;
  final String? toAccountNo;
  final String? toAccountName;
  final String? toBankName;
  final String currency;
  final String? description;
  final String accountSourceId;
  final String? accountBankId;
  final String? ofAccountId;
  final DateTime transactionDateTime;
  final AccountSource accountSource;

  Transaction({
    required this.id,
    required this.direction,
    this.transactionId,
    required this.amount,
    this.toAccountNo,
    this.toAccountName,
    this.toBankName,
    required this.currency,
    this.description,
    required this.accountSourceId,
    this.accountBankId,
    this.ofAccountId,
    required this.transactionDateTime,
    required this.accountSource,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      direction: json['direction'],
      transactionId: json['transactionId'],
      amount: json['amount'],
      toAccountNo: json['toAccountNo'],
      toAccountName: json['toAccountName'],
      toBankName: json['toBankName'],
      currency: json['currency'],
      description: json['description'],
      accountSourceId: json['accountSourceId'],
      accountBankId: json['accountBankId'],
      ofAccountId: json['ofAccountId'],
      transactionDateTime: DateTime.parse(json['transactionDateTime']),
      accountSource: AccountSource.fromJson(json['accountSource']),
    );
  }
} 