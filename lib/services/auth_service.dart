import 'package:flutter/material.dart';
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
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  ClickFixUser? currentUser;

  /// Logs in against the backend Laravel REST API.
  Future<bool> login(String email, String password) async {
    final result = await ApiService().login(email, password);
    if (result['status'] == true && result.containsKey('data')) {
      currentUser = ClickFixUser.fromJson(result['data']);
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
      if (result.containsKey('access_token')) {
        ApiService().setToken(result['access_token']);
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
      return true;
    }
    return false;
  }

  /// Logs out of active backend session.
  Future<void> logout() async {
    await ApiService().logout();
    currentUser = null;
  }

  bool get isLoggedIn => currentUser != null;
}
