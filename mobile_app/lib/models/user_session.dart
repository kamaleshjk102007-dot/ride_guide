class UserSession {
  UserSession({
    required this.token,
    required this.role,
    required this.userId,
    required this.name,
    required this.email,
  });

  final String token;
  final String role;
  final String userId;
  final String name;
  final String email;
}
