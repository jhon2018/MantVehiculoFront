// ARCHIVO lib/core/services/session_manager.dart
import '../models/user_session.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  UserSession? _user;

  void setUser(UserSession user) {
    _user = user;
  }

  UserSession? get user => _user;
}
