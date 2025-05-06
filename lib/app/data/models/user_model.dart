class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? avatar;
  final int level;
  final int points;
  final DateTime? membershipExpiry;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.avatar,
    this.level = 0,
    this.points = 0,
    this.membershipExpiry,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      level: json['level'] ?? 0,
      points: json['points'] ?? 0,
      membershipExpiry: json['membership_expiry'] != null
          ? DateTime.parse(json['membership_expiry'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'level': level,
      'points': points,
      'membership_expiry': membershipExpiry?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    int? level,
    int? points,
    DateTime? membershipExpiry,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      level: level ?? this.level,
      points: points ?? this.points,
      membershipExpiry: membershipExpiry ?? this.membershipExpiry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPremium => level >= 1;
  bool get isPro => level >= 2;
  bool get isMembershipActive => membershipExpiry != null && membershipExpiry!.isAfter(DateTime.now());
}
