import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clickfix/services/api_service.dart';

class ClickFixUser {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String city;
  final String role; // 'customer', 'worker', 'admin'
  final int? serviceId;
  final String? profilePicture;
  final String? description;
  final String address;
  Color avatarColor;

  ClickFixUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.city,
    required this.role,
    this.serviceId,
    this.profilePicture,
    this.description,
    this.address = '',
    this.avatarColor = Colors.amber,
  });

  factory ClickFixUser.fromJson(Map<String, dynamic> json) {
    Color color = Colors.teal;
    final r = (json['role'] ?? 'customer').toString().toLowerCase();
    if (r == 'admin') {
      color = Colors.deepOrange;
    } else if (r == 'customer') {
      color = Colors.blue;
    }

    if (json.containsKey('avatar_color_value') && json['avatar_color_value'] != null) {
      color = Color(json['avatar_color_value'] as int);
    }

    return ClickFixUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      city: json['city'] ?? '',
      role: json['role'] ?? 'customer',
      serviceId: json['service_id'],
      profilePicture: json['profile_picture'],
      description: json['description'],
      address: json['address'] ?? '',
      avatarColor: color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'city': city,
      'role': role,
      'service_id': serviceId,
      'profile_picture': profilePicture,
      'description': description,
      'address': address,
      'avatar_color_value': avatarColor.value,
    };
  }
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  ClickFixUser? currentUser;

  /// Save active login session to local storage.
  Future<void> saveSession(String token, ClickFixUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_data', json.encode(user.toJson()));
      await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  /// Load login session from local storage if valid.
  /// Valid session means session is less than 48 hours (2 days) old.
  Future<bool> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userDataStr = prefs.getString('user_data');
      final timestamp = prefs.getInt('login_timestamp');

      if (token == null || userDataStr == null || timestamp == null) {
        return false;
      }

      // Check if session has expired (48 hours = 2 days)
      final loginTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final difference = DateTime.now().difference(loginTime);
      if (difference.inHours >= 48) {
        await clearSession();
        return false;
      }

      // Restore session
      ApiService().setToken(token);
      currentUser = ClickFixUser.fromJson(json.decode(userDataStr));
      return true;
    } catch (e) {
      debugPrint('Error loading session: $e');
      return false;
    }
  }

  /// Clear the local login session.
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('login_timestamp');
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }

  /// Logs in against the backend Laravel REST API.
  Future<bool> login(String email, String password) async {
    final result = await ApiService().login(email, password);
    if (result['status'] == true && result.containsKey('data')) {
      currentUser = ClickFixUser.fromJson(result['data']);
      final token = result['access_token'] ?? ApiService().token;
      if (token != null) {
        await saveSession(token, currentUser!);
      }
      return true;
    }
    return false;
  }

  /// Registers user against the backend Laravel REST API.
  Future<bool> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String city,
    required String role,
    int? serviceId,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await ApiService().register(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      city: city,
      role: role.toLowerCase(),
      serviceId: serviceId,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    if (result['status'] == true && result.containsKey('data')) {
      currentUser = ClickFixUser.fromJson(result['data']);
      final token = result['access_token'] ?? ApiService().token;
      if (token != null) {
        ApiService().setToken(token);
        await saveSession(token, currentUser!);
      }
      return true;
    }
    return false;
  }

  /// Setup final profile configurations on backend.
  Future<bool> completeProfile(Color color, String address, String city) async {
    if (currentUser == null) return false;
    
    final result = await ApiService().updateProfile(
      name: currentUser!.name,
      email: currentUser!.email,
      city: city,
      description: address, // Map street address details into description field
    );

    if (result['status'] == true && result.containsKey('data')) {
      currentUser = ClickFixUser.fromJson(result['data']);
      currentUser!.avatarColor = color; // Maintain selected theme color locally
      
      // Update saved user session details in local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(currentUser!.toJson()));
      return true;
    }
    return false;
  }

  /// Logs out of active backend session.
  Future<void> logout() async {
    await ApiService().logout();
    currentUser = null;
    await clearSession();
  }

  bool get isLoggedIn => currentUser != null;
}
