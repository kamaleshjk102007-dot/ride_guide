class UserSession {
  UserSession({
    required this.token,
    required this.role,
    required this.userId,
    required this.visitorId,
    required this.name,
    required this.email,
    this.phone,
    this.age,
    this.status,
    this.profileImagePath,
  });

  final String token;
  final String role;
  final String userId;
  final String visitorId;
  final String name;
  final String email;
  final String? phone;
  final int? age;
  final String? status;
  final String? profileImagePath;

  Map<String, dynamic> toJson() => {
        'token': token,
        'role': role,
        'userId': userId,
        'visitorId': visitorId,
        'name': name,
        'email': email,
        'phone': phone,
        'age': age,
        'status': status,
        'profileImagePath': profileImagePath,
      };

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
        token: json['token'] ?? '',
        role: json['role'] ?? 'visitor',
        userId: json['userId'] ?? '',
        visitorId: json['visitorId'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'],
        age: json['age'],
        status: json['status'],
        profileImagePath: json['profileImagePath'],
      );
}
