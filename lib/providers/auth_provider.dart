import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/api_config.dart';

class UserModel {
  final int userId;
  final String fullname;
  final String phone;
  final String email;
  final String role;
  final String? expertise;
  final String? vehiclePlate;
  final String? vehicleModel;

  UserModel({
    required this.userId,
    required this.fullname,
    required this.phone,
    this.email = '',
    this.role = 'technician',
    this.expertise,
    this.vehiclePlate,
    this.vehicleModel,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      fullname: json['fullname'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'technician',
      expertise: json['expertise'],
      vehiclePlate: json['vehicle_plate'],
      vehicleModel: json['vehicle_model'],
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'fullname': fullname,
    'phone': phone,
    'email': email,
    'role': role,
    'expertise': expertise,
    'vehicle_plate': vehiclePlate,
    'vehicle_model': vehicleModel,
  };
}

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String _errorMessage = '';
  bool _isOnline = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isOnline => _isOnline;

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final token = await _storage.getToken();
      if (token == null || token.isEmpty) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      _api.setToken(token);
      final response = await _api.get(ApiConfig.getProfile);
      
      if (response.success && response.data != null) {
        final userData = response.data!['user'] ?? response.data!['data'];
        if (userData != null) {
          _user = UserModel.fromJson(userData);
          _status = AuthStatus.authenticated;
        } else {
          await _logout();
        }
      } else {
        await _logout();
      }
    } catch (e) {
      await _logout();
    }
    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    final response = await _api.post(ApiConfig.login, body: {'phone': phone, 'password': password});

    if (response.success && response.data != null) {
      final token = response.data!['token'];
      final userData = response.data!['user'];

      if (userData != null && userData['role'] != 'technician') {
        _errorMessage = 'บัญชีนี้ไม่ใช่บัญชีช่าง';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }

      if (token != null && userData != null) {
        await _storage.saveToken(token);
        await _storage.saveUserId(userData['user_id']);
        await _storage.saveUserData(jsonEncode(userData));

        _api.setToken(token);
        _user = UserModel.fromJson(userData);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
    }

    _errorMessage = response.message;
    _status = AuthStatus.error;
    notifyListeners();
    return false;
  }

  Future<bool> setOnlineStatus(bool online) async {
    final response = await _api.post(ApiConfig.setOnlineStatus, body: {'is_online': online ? 1 : 0});
    if (response.success) {
      _isOnline = online;
      notifyListeners();
    }
    return response.success;
  }

  Future<void> logout() async {
    await setOnlineStatus(false);
    await _logout();
    notifyListeners();
  }

  Future<void> _logout() async {
    await _storage.clearAll();
    _api.setToken(null);
    _user = null;
    _isOnline = false;
    _status = AuthStatus.unauthenticated;
  }
}
