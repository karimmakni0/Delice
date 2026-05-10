import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/api/api_client.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> tryAutoLogin() async {
    final token = await ApiClient.getToken();
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      if (userJson != null) {
        _user = UserModel.fromJson(jsonDecode(userJson));
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    try {
      final data = await AuthService.login(email, password);
      _user = UserModel.fromJson(data['user']);
      await _saveUser();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> body) async {
    _error = null;
    try {
      final data = await AuthService.register(body);
      _user = UserModel.fromJson(data['user']);
      await _saveUser();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    _user = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      final data = await AuthService.getMe();
      _user = UserModel.fromJson(data['user']);
      await _saveUser();
      notifyListeners();
    } catch (_) {}
  }

  void updatePoints(int newBalance) {
    if (_user == null) return;
    _user = UserModel(
      id: _user!.id,
      name: _user!.name,
      email: _user!.email,
      role: _user!.role,
      magasinName: _user!.magasinName,
      phone: _user!.phone,
      address: _user!.address,
      pointsBalance: newBalance,
    );
    _saveUser();
    notifyListeners();
  }

  Future<void> _saveUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode({
      'id': _user!.id,
      'name': _user!.name,
      'email': _user!.email,
      'role': _user!.role,
      'magasin_name': _user!.magasinName,
      'phone': _user!.phone,
      'address': _user!.address,
      'points_balance': _user!.pointsBalance,
    }));
  }
}
