class ExpenditureFundResponse {
  final Pagination pagination;
  final List<ExpenditureFund> data;
  final int statusCode;

  ExpenditureFundResponse({
    required this.pagination,
    required this.data,
    required this.statusCode,
  });

  factory ExpenditureFundResponse.fromJson(Map<String, dynamic> json) {
    return ExpenditureFundResponse(
      pagination: Pagination.fromJson(json['pagination']),
      data: (json['data'] as List).map((e) => ExpenditureFund.fromJson(e)).toList(),
      statusCode: json['statusCode'],
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
      totalPage: json['totalPage'],
      currentPage: json['currentPage'],
      limit: json['limit'],
      skip: json['skip'],
    );
  }
}

class ExpenditureFund {
  final String id;
  final String name;
  final String? description;
  final String status;
  final double currentAmount;
  final String currency;
  final DateTime createdAt;
  final String createdBy;
  final DateTime updatedAt;
  final String? updatedBy;
  final DateTime? deletedAt;
  final String? deletedBy;
  final User? defaultForUser;
  final User owner;
  final List<Participant> participants;
  final int countParticipants;
  final List<dynamic> categories;
  final DateTime time;
  final List<dynamic> transactions;

  ExpenditureFund({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.currentAmount,
    required this.currency,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
    this.defaultForUser,
    required this.owner,
    required this.participants,
    required this.countParticipants,
    required this.categories,
    required this.time,
    required this.transactions,
  });

  factory ExpenditureFund.fromJson(Map<String, dynamic> json) {
    return ExpenditureFund(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      currentAmount: json['currentAmount'].toDouble(),
      currency: json['currency'],
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
      updatedAt: DateTime.parse(json['updatedAt']),
      updatedBy: json['updatedBy'],
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      deletedBy: json['deletedBy'],
      defaultForUser: json['defaultForUser'] != null ? User.fromJson(json['defaultForUser']) : null,
      owner: User.fromJson(json['owner']),
      participants: (json['participants'] as List).map((e) => Participant.fromJson(e)).toList(),
      countParticipants: json['countParticipants'],
      categories: json['categories'],
      time: DateTime.parse(json['time']),
      transactions: json['transactions'],
    );
  }
}

class User {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? avatarId;
  final String? gender;
  final String? address;
  final String? workplace;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.avatarId,
    this.gender,
    this.address,
    this.workplace,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      avatarId: json['avatarId'],
      gender: json['gender'],
      address: json['address'],
      workplace: json['workplace'],
    );
  }
}

class Participant {
  final String id;
  final String role;
  final User user;
  final String? subEmail;
  final String? tokenAcceped;
  final String status;

  Participant({
    required this.id,
    required this.role,
    required this.user,
    this.subEmail,
    this.tokenAcceped,
    required this.status,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      role: json['role'],
      user: User.fromJson(json['user']),
      subEmail: json['subEmail'],
      tokenAcceped: json['tokenAcceped'],
      status: json['status'],
    );
  }
} 