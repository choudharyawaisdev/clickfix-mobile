import 'package:flutter/material.dart';

class ClickFixUser {
  final String name;
  final String email;
  final String role; // 'Customer', 'Worker', 'Admin'
  final String password;
  Color avatarColor;
  String address;
  String city;

  ClickFixUser({
    required this.name,
    required this.email,
    required this.role,
    required this.password,
    this.avatarColor = Colors.amber,
    this.address = '',
    this.city = '',
  });
}

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Active user session
  ClickFixUser? currentUser;

  // Mock memory database of registered users
  final List<ClickFixUser> _usersDb = [
    ClickFixUser(
      name: 'Platform Admin',
      email: 'admin@clickfix.com',
      role: 'Admin',
      password: 'admin123',
      avatarColor: Colors.deepOrange,
      address: 'Admin Headquarters',
      city: 'Islamabad',
    ),
    ClickFixUser(
      name: 'Hafiz Talha (Customer)',
      email: 'customer@clickfix.com',
      role: 'Customer',
      password: 'customer123',
      avatarColor: Colors.blue,
      address: 'D-Ground Main Road',
      city: 'Faisalabad',
    ),
    ClickFixUser(
      name: 'Awais Choudhary (Pro)',
      email: 'worker@clickfix.com',
      role: 'Worker',
      password: 'worker123',
      avatarColor: Colors.teal,
      address: 'Gulberg 3 Blocks',
      city: 'Lahore',
    ),
  ];

  /// Login attempt. Returns true if credentials match.
  bool login(String email, String password) {
    try {
      final user = _usersDb.firstWhere(
        (u) => u.email.trim().toLowerCase() == email.trim().toLowerCase() && u.password == password,
      );
      currentUser = user;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Initial Registration step. Adds user to db, but setup is incomplete until step 2.
  bool register(String name, String email, String password, String role) {
    // Check if user already exists
    final exists = _usersDb.any((u) => u.email.trim().toLowerCase() == email.trim().toLowerCase());
    if (exists) return false;

    final newUser = ClickFixUser(
      name: name,
      email: email,
      role: role,
      password: password,
    );
    _usersDb.add(newUser);
    currentUser = newUser;
    return true;
  }

  /// Final Setup step. Save avatar, address, and city location.
  void completeProfile(Color color, String address, String city) {
    if (currentUser != null) {
      currentUser!.avatarColor = color;
      currentUser!.address = address;
      currentUser!.city = city;
    }
  }

  /// Logout active session.
  void logout() {
    currentUser = null;
  }

  /// Helper to check if someone is logged in.
  bool get isLoggedIn => currentUser != null;
}
