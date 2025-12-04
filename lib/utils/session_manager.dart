import '../models/user.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  User? currentUser;

  void login(User user) {
    currentUser = user;
  }

  void logout() {
    currentUser = null;
  }
}
