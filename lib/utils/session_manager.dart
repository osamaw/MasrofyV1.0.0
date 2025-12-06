import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class SessionManager {
  
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  User? currentUser; 

  
  Future<void> login(User user) async {
    currentUser = user; 
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', user.Email); 
  }

  Future<void> logout() async {
    currentUser = null; 
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email'); 
  }


  Future<String?> getCachedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }
}