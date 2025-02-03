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
  final String? phoneNumber;
  final String? avatarId;
  final String? gender;
  final String? address;
  final String? workplace;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.avatarId,
    this.gender,
    this.address,
    this.workplace,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      avatarId: json['avatarId'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      workplace: json['workplace'] as String?,
    );
  }
}

class Participant {
  final String id;
  final String role;
  final String status;
  final User user;

  Participant({
    required this.id,
    required this.role,
    required this.status,
    required this.user,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] as String,
      role: json['role'] as String,
      status: json['status'] ?? 'PENDING',
      user: User.fromJson(json['user'] as Map<String, dynamic>),
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
  final String? createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final DateTime? deletedAt;
  final String? deletedBy;
  final User? defaultForUser;
  final User owner;
  final List<Participant> participants;
  final int countParticipants;

  ExpenditureFund({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.currentAmount,
    required this.currency,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
    this.defaultForUser,
    required this.owner,
    required this.participants,
    required this.countParticipants,
  });

  factory ExpenditureFund.fromJson(Map<String, dynamic> json) {
    return ExpenditureFund(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      currentAmount: (json['currentAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      updatedBy: json['updatedBy'] as String?,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      deletedBy: json['deletedBy'] as String?,
      defaultForUser: json['defaultForUser'] != null
          ? User.fromJson(json['defaultForUser'] as Map<String, dynamic>)
          : null,
      owner: User.fromJson(json['owner'] as Map<String, dynamic>),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => Participant.fromJson(e as Map<String, dynamic>))
          .toList(),
      countParticipants: json['participants']?.length ?? 0,
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
