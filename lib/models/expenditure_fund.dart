class ExpenditureFundResponse {
  final List<ExpenditureFund> data;
  final Map<String, dynamic> pagination;

  ExpenditureFundResponse({
    required this.data,
    required this.pagination,
  });

  factory ExpenditureFundResponse.fromJson(Map<String, dynamic> json) {
    return ExpenditureFundResponse(
      data: (json['data'] as List)
          .map((item) => ExpenditureFund.fromJson(item))
          .toList(),
      pagination: json['pagination'],
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

class ExpenditureFund {
  final String id;
  final String name;
  final String description;
  final String status;
  final double currentAmount;
  final String currency;
  final DateTime createdAt;
  final String createdBy;
  final User? defaultForUser;
  final User owner;
  final List<Participant> participants;
  final int countParticipants;

  ExpenditureFund({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.currentAmount,
    required this.currency,
    required this.createdAt,
    required this.createdBy,
    this.defaultForUser,
    required this.owner,
    required this.participants,
    required this.countParticipants,
  });

  factory ExpenditureFund.fromJson(Map<String, dynamic> json) {
    return ExpenditureFund(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      status: json['status'],
      currentAmount: (json['currentAmount'] ?? 0).toDouble(),
      currency: json['currency'],
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
      defaultForUser: json['defaultForUser'] != null 
          ? User.fromJson(json['defaultForUser'])
          : null,
      owner: User.fromJson(json['owner']),
      participants: (json['participants'] as List)
          .map((p) => Participant.fromJson(p))
          .toList(),
      countParticipants: json['countParticipants'],
    );
  }
}

class CreateFundResponse {
  final CreateFundData data;
  final int statusCode;

  CreateFundResponse({
    required this.data,
    required this.statusCode,
  });

  factory CreateFundResponse.fromJson(Map<String, dynamic> json) {
    return CreateFundResponse(
      data: CreateFundData.fromJson(json['data']),
      statusCode: json['statusCode'],
    );
  }
}

class CreateFundData {
  final String id;
  final String name;
  final String? description;
  final String status;
  final double currentAmount;
  final String currency;

  CreateFundData({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.currentAmount,
    required this.currency,
  });

  factory CreateFundData.fromJson(Map<String, dynamic> json) {
    return CreateFundData(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      currentAmount: json['currentAmount'].toDouble(),
      currency: json['currency'],
    );
  }
}
