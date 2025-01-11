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
  final dynamic accountBank;
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
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      initAmount: json['initAmount'] as int,
      accountBankId: json['accountBankId'] as String?,
      currency: json['currency'] as String,
      currentAmount: json['currentAmount'] as int,
      userId: json['userId'] as String,
      fundId: json['fundId'] as String,
      participantId: json['participantId'] as String?,
      accountBank: json['accountBank'],
      accounts: json['accounts'] != null 
          ? List<String>.from(json['accounts'] as List)
          : null,
    );
  }
}
