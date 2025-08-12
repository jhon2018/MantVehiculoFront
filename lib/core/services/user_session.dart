// ARCHIVO lib/core/services/session_manager.dart
import 'package:mantenimientovehiculos/core/models/user_session.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  UserSession? _user;

  UserSession? get user => _user;

  void setUser(UserSession user) {
    _user = user;
  }

  void clear() {
    _user = null;
  }

  bool get isLoggedIn => _user != null;
}
