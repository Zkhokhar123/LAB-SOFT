import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _currentUsername = '';
  Map<String, String> _users = {};
  bool _isLoading = true;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get currentUsername => _currentUsername;
  bool get isLoading => _isLoading;
  Map<String, String> get users => _users;

  AuthController() {
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load logged in state
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _currentUsername = prefs.getString('current_username') ?? '';

    // Load registered offline users
    final String? usersJson = prefs.getString('offline_users');
    if (usersJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(usersJson);
        _users = decoded.map((key, value) => MapEntry(key, value.toString()));
      } catch (e) {
        _users = {'admin': 'admin'};
      }
    } else {
      // Default offline account: admin / admin
      _users = {'admin': 'admin'};
      await _saveUsers();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> reloadFromStorage() async {
    _isLoading = true;
    notifyListeners();
    await _loadAuthData();
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('offline_users', json.encode(_users));
  }

  Future<bool> login(String username, String password) async {
    final normalizedUsername = username.trim().toLowerCase();
    
    if (_users.containsKey(normalizedUsername) && _users[normalizedUsername] == password) {
      _isLoggedIn = true;
      _currentUsername = username.trim();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('current_username', _currentUsername);
      
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password) async {
    final normalizedUsername = username.trim().toLowerCase();
    
    if (normalizedUsername.isEmpty || password.isEmpty) return false;
    if (_users.containsKey(normalizedUsername)) return false; // User already exists

    _users[normalizedUsername] = password;
    await _saveUsers();
    
    notifyListeners();
    return true;
  }

  Future<bool> changePassword(String username, String oldPassword, String newPassword) async {
    final normalizedUsername = username.trim().toLowerCase();
    if (!_users.containsKey(normalizedUsername)) return false;
    if (_users[normalizedUsername] != oldPassword) return false;

    _users[normalizedUsername] = newPassword;
    await _saveUsers();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUsername = '';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.setString('current_username', '');
    
    notifyListeners();
  }
}

// Global instance of the AuthController
final authController = AuthController();
