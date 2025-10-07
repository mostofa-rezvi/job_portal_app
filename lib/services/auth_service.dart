import 'package:project/database/database_helper.dart';
import 'package:project/models/user.dart';
import 'package:project/services/shared_preference_service.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SharedPreferenceService _prefs = SharedPreferenceService();

  Future<String?> register(String name, String email, String password) async {
    final existingUser = await _dbHelper.getUserByEmail(email);
    if (existingUser != null) {
      return "Email already registered!";
    }

    final user = User(
      username: name,
      email: email,
      password: password,
    );

    await _dbHelper.insertUser(user);
    await _prefs.setLoggedIn(true);
    await _prefs.setCurrentUserEmail(email);
    await _prefs.setCurrentUsername(name);
    return null;
  }

  Future<String?> login(String email, String password) async {
    final user = await _dbHelper.getUserByEmail(email);
    if (user == null) return "User not found!";
    if (user.password != password) return "Incorrect password!";

    await _prefs.setLoggedIn(true);
    await _prefs.setCurrentUserEmail(email);
    await _prefs.setCurrentUsername(user.username);
    return null;
  }

  Future<void> logout() async {
    await _prefs.clearUserData();
  }
}
