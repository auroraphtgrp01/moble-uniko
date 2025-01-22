class TrackerTransactionDetail {
  final String id;
  final String reasonName;
  final String? description;
  final TrackerTypeDetail trackerType;
  final TransactionDetail transaction;
  final ParticipantDetail participant;
  final FundDetail fund;
  final DateTime time;

  TrackerTransactionDetail({
    required this.id,
    required this.reasonName,
    this.description,
    required this.trackerType,
    required this.transaction,
    required this.participant,
    required this.fund,
    required this.time,
  });

  factory TrackerTransactionDetail.fromJson(Map<String, dynamic> json) {
    return TrackerTransactionDetail(
      id: json['id'] ?? '',
      reasonName: json['reasonName'] ?? '',
      description: json['description'],
      trackerType: TrackerTypeDetail.fromJson(json['TrackerType'] ?? {}),
      transaction: TransactionDetail.fromJson(json['Transaction'] ?? {}),
      participant: ParticipantDetail.fromJson(json['participant'] ?? {}),
      fund: FundDetail.fromJson(json['fund'] ?? {}),
      time: json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
    );
  }
}

class TrackerTypeDetail {
  final String id;
  final String name;
  final String type;
  final String description;

  TrackerTypeDetail({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
  });

  factory TrackerTypeDetail.fromJson(Map<String, dynamic> json) {
    return TrackerTypeDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class TransactionDetail {
  final String id;
  final int amount;
  final String direction;
  final DateTime transactionDateTime;
  final String? toAccountName;
  final String? toAccountNo;
  final String? toBankName;
  final String? description;
  final AccountDetail? ofAccount;
  final AccountSourceDetail accountSource;

  TransactionDetail({
    required this.id,
    required this.amount,
    required this.direction,
    required this.transactionDateTime,
    this.toAccountName,
    this.toAccountNo,
    this.toBankName,
    this.description,
    this.ofAccount,
    required this.accountSource,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      id: json['id'] ?? '',
      amount: json['amount'] ?? 0,
      direction: json['direction'] ?? '',
      transactionDateTime: json['transactionDateTime'] != null
          ? DateTime.parse(json['transactionDateTime'])
          : DateTime.now(),
      toAccountName: json['toAccountName'],
      toAccountNo: json['toAccountNo'],
      toBankName: json['toBankName'],
      description: json['description'],
      ofAccount: json['ofAccount'] != null
          ? AccountDetail.fromJson(json['ofAccount'])
          : null,
      accountSource: AccountSourceDetail.fromJson(json['accountSource'] ?? {}),
    );
  }
}

class AccountDetail {
  final String accountNo;

  AccountDetail({required this.accountNo});

  factory AccountDetail.fromJson(Map<String, dynamic> json) {
    return AccountDetail(accountNo: json['accountNo'] ?? '');
  }
}

class AccountSourceDetail {
  final String id;
  final String name;
  final String type;
  final int initAmount;
  final String currency;
  final int currentAmount;

  AccountSourceDetail({
    required this.id,
    required this.name,
    required this.type,
    required this.initAmount,
    required this.currency,
    required this.currentAmount,
  });

  factory AccountSourceDetail.fromJson(Map<String, dynamic> json) {
    return AccountSourceDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      initAmount: json['initAmount'] ?? 0,
      currency: json['currency'] ?? '',
      currentAmount: json['currentAmount'] ?? 0,
    );
  }
}

class ParticipantDetail {
  final String id;
  final UserDetail user;

  ParticipantDetail({
    required this.id,
    required this.user,
  });

  factory ParticipantDetail.fromJson(Map<String, dynamic> json) {
    return ParticipantDetail(
      id: json['id'] ?? '',
      user: UserDetail.fromJson(json['user'] ?? {}),
    );
  }
}

class UserDetail {
  final String id;
  final String fullName;
  final String email;

  UserDetail({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class FundDetail {
  final String id;
  final String name;

  FundDetail({
    required this.id,
    required this.name,
  });

  factory FundDetail.fromJson(Map<String, dynamic> json) {
    return FundDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
