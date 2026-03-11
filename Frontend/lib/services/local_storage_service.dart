import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // Get SharedPreferences instance
  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // User Model
  static Map<String, dynamic> createUser({
    required String name,
    required String email,
    required String password,
    required String healthIssues,
  }) {
    return {
      'name': name,
      'email': email,
      'password': password,
      'healthIssues': healthIssues,
    };
  }

  // Get all users
  static Future<List<Map<String, dynamic>>> getUsers() async {
    final prefs = await _prefs;
    final String? usersJson = prefs.getString(_usersKey);
    if (usersJson == null || usersJson.isEmpty) {
      return [];
    }
    List<dynamic> usersList = jsonDecode(usersJson);
    return usersList.cast<Map<String, dynamic>>();
  }

  // Save users list
  static Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await _prefs;
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  // Register new user
  static Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String healthIssues,
  }) async {
    final users = await getUsers();
    
    // Check if email already exists
    final existingUser = users.any((user) => user['email'] == email);
    if (existingUser) {
      return false;
    }

    // Add new user
    users.add(createUser(
      name: name,
      email: email,
      password: password,
      healthIssues: healthIssues,
    ));

    await _saveUsers(users);
    return true;
  }

  // Login user
  static Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final users = await getUsers();
    
    for (var user in users) {
      if (user['email'] == email && user['password'] == password) {
        // Save current user and login status
        final prefs = await _prefs;
        await prefs.setString(_currentUserKey, jsonEncode(user));
        await prefs.setBool(_isLoggedInKey, true);
        return user;
      }
    }
    return null;
  }

  // Logout user
  static Future<void> logoutUser() async {
    final prefs = await _prefs;
    await prefs.remove(_currentUserKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await _prefs;
    final String? userJson = prefs.getString(_currentUserKey);
    if (userJson == null || userJson.isEmpty) {
      return null;
    }
    return jsonDecode(userJson);
  }

  // Update user profile
  static Future<bool> updateUser({
    required String name,
    required String email,
    required String healthIssues,
  }) async {
    final users = await getUsers();
    final prefs = await _prefs;
    final String? currentUserJson = prefs.getString(_currentUserKey);
    
    if (currentUserJson == null) return false;
    
    Map<String, dynamic> currentUser = jsonDecode(currentUserJson);
    
    // Find and update user in list
    for (int i = 0; i < users.length; i++) {
      if (users[i]['email'] == currentUser['email']) {
        users[i]['name'] = name;
        users[i]['email'] = email;
        users[i]['healthIssues'] = healthIssues;
        
        // Update stored password (keep the same)
        users[i]['password'] = currentUser['password'];
        
        await _saveUsers(users);
        
        // Update current user session
        await prefs.setString(_currentUserKey, jsonEncode(users[i]));
        return true;
      }
    }
    return false;
  }

  // Update password
  static Future<bool> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final users = await getUsers();
    final prefs = await _prefs;
    final String? currentUserJson = prefs.getString(_currentUserKey);
    
    if (currentUserJson == null) return false;
    
    Map<String, dynamic> currentUser = jsonDecode(currentUserJson);
    
    // Find and update user password
    for (int i = 0; i < users.length; i++) {
      if (users[i]['email'] == currentUser['email'] && 
          users[i]['password'] == oldPassword) {
        users[i]['password'] = newPassword;
        await _saveUsers(users);
        
        // Update current user session
        await prefs.setString(_currentUserKey, jsonEncode(users[i]));
        return true;
      }
    }
    return false;
  }
}

