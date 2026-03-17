class UserSession {
  UserSession({
    required this.token,
    required this.role,
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.age,
    this.profileImagePath,
  });

  final String token;
  final String role;
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final int? age;
  final String? profileImagePath;

  Map<String, dynamic> toJson() => {
        'token': token,
        'role': role,
        'userId': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'age': age,
        'profileImagePath': profileImagePath,
      };

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
        token: json['token'] ?? '',
        role: json['role'] ?? 'visitor',
        userId: json['userId'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'],
        age: json['age'],
        profileImagePath: json['profileImagePath'],
      );
}
