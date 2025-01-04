// lib/models/account_source.dart

import 'dart:convert';

class AccountSource {
  final String name;
  final String accountSourceType;
  final int initAmount;
  final String? password;
  final String? loginId;
  final String? type;
  final List<String>? accounts;
  final String fundId;

  AccountSource({
    required this.name,
    required this.accountSourceType,
    required this.initAmount,
    this.password,
    this.loginId,
    this.type,
    required this.accounts,
    required this.fundId,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'name': name,
      'accountSourceType': accountSourceType,
      'initAmount': initAmount,
      'fundId': fundId,
    };
    if (password != null) data['password'] = password!;
    if (loginId != null) data['login_id'] = loginId!;
    if (type != null) data['type'] = type!;
    if(accounts != null) data['account'] = accounts!;
    return data;
  }

  factory AccountSource.fromJson(Map<String, dynamic> json) {
  return AccountSource(
    name: json['name'] ?? '',
    accountSourceType: json['accountSourceType'] ?? '',
    initAmount: json['initAmount'] ?? 0,
    password: json['password'],
    loginId: json['login_id'],
    type: json['type'],
    accounts: json['accounts'],
    fundId: json['fundId'] ?? '',
  );
}
}
