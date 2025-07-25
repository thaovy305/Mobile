class Account {
  final int id;
  final String username;
  final String? fullName;
  final String email;
  final String? password;
  final String? role;
  final String? position;
  final String? phone;
  final String? gender;
  final String? googleId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? status;
  final String? address;
  final String? picture;
  final DateTime? dateOfBirth;

  Account({
    required this.id,
    required this.username,
    this.fullName,
    required this.email,
    this.password,
    this.role,
    this.position,
    this.phone,
    this.gender,
    this.googleId,
    required this.createdAt,
    required this.updatedAt,
    this.status,
    this.address,
    this.picture,
    this.dateOfBirth,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as int,
      username: json['username'] as String,
      fullName: json['fullName'] as String?,
      email: json['email'] as String,
      password: json['password'] as String?,
      role: json['role'] as String?,
      position: json['position'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      googleId: json['googleId'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
      status: json['status'] as String?,
      address: json['address'] as String?,
      picture: json['picture'] as String?,
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth'] as String) : null,
    );
  }
}