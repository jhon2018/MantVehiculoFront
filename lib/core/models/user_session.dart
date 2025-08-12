// ARCHIVO lib/core/models/user_session.dart
class UserSession {
  final String nombreCompleto;
  final String rol;
  final String? token;

  UserSession({
    required this.nombreCompleto,
    required this.rol,
    this.token,
  });
}
