// lib/models/account_source.dart

import 'dart:convert';

class AccountSourceResponse {
  final Pagination pagination;
  final List<AccountSource> data;
  final int statusCode;

  AccountSourceResponse({
    required this.pagination,
    required this.data,
    required this.statusCode,
  });

  factory AccountSourceResponse.fromJson(Map<String, dynamic> json) {
    return AccountSourceResponse(
      pagination: Pagination.fromJson(json['pagination']),
      data: (json['data'] as List<dynamic>)
          .map((e) => AccountSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusCode: json['statusCode'] as int,
    );
  }
}

class Pagination {
  final int totalPage;
  final int currentPage;
  final int limit;
  final int skip;

  Pagination({
    required this.totalPage,
    required this.currentPage,
    required this.limit,
    required this.skip,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalPage: json['totalPage'] as int,
      currentPage: json['currentPage'] as int,
      limit: json['limit'] as int,
      skip: json['skip'] as int,
    );
  }
}

class AccountBank {
  final String id;
  final String type;
  final String loginId;
  final List<BankAccount> accounts;

  AccountBank({
    required this.id,
    required this.type,
    required this.loginId,
    required this.accounts,
  });

  factory AccountBank.fromJson(Map<String, dynamic> json) {
    return AccountBank(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      loginId: json['login_id'] ?? '',
      accounts: (json['accounts'] as List?)
          ?.map((acc) => BankAccount.fromJson(acc))
          .toList() ?? [],
    );
  }
}

class BankAccount {
  final String accountNo;

  BankAccount({required this.accountNo});

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      accountNo: json['accountNo'] ?? '',
    );
  }
}

class AccountSource {
  final String id;
  final String name;
  final String type;
  final int initAmount;
  final String? accountBankId;
  final String currency;
  final int currentAmount;
  final String userId;
  final String fundId;
  final String? participantId;
  Map<String, dynamic>? accountBank;
  final List<String>? accounts;

  AccountSource({
    required this.id,
    required this.name,
    required this.type,
    required this.initAmount,
    this.accountBankId,
    required this.currency,
    required this.currentAmount,
    required this.userId,
    required this.fundId,
    this.participantId,
    this.accountBank,
    this.accounts,
  });

  factory AccountSource.fromJson(Map<String, dynamic> json) {
  return AccountSource(
    id: json['id'] ?? '', 
    name: json['name'] ?? '',
    type: json['type'] ?? '',
    initAmount: json['initAmount'] ?? 0, 
    accountBankId: json['accountBankId'] != null ? json['accountBankId'] as String : null,
    currency: json['currency'] ?? '',
    currentAmount: json['currentAmount'] ?? 0,
    userId: json['userId'] ?? '',
    fundId: json['fundId'] ?? '',
    participantId: json['participantId'] != null ? json['participantId'] as String : null,
    accountBank: json['accountBank'] != null
        ? Map<String, dynamic>.from(json['accountBank'])
        : null,
    accounts: json['accounts'] != null
        ? List<String>.from(json['accounts'] as List)
        : null,
  );
}

}
