class Participant {
  final String id;
  final String? subEmail;
  final String fundId;
  final String userId;
  final String role;
  final int contributedAmount;
  final String? tokenAcceped;
  final User user;

  Participant({
    required this.id,
    this.subEmail,
    required this.fundId,
    required this.userId,
    required this.role,
    required this.contributedAmount,
    this.tokenAcceped,
    required this.user,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      subEmail: json['subEmail'],
      fundId: json['fundId'],
      userId: json['userId'],
      role: json['role'],
      contributedAmount: json['contributedAmount'],
      tokenAcceped: json['tokenAcceped'],
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final String id;
  final String? profession;
  final String fullName;
  final String? dateOfBirth;
  final String? gender;
  final String? username;
  final String email;

  User({
    required this.id,
    this.profession,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.username,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      profession: json['profession'],
      fullName: json['fullName'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      username: json['username'],
      email: json['email'],
    );
  }
} 