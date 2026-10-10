import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // State variables
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  String get userRole => _userData?['role'] ?? 'student';
  String getUserName() => _userData?['name'] ?? 'User';

  // ==================== INITIALIZE ====================
  Future<void> initialize() async {
    _user = _authService.currentUser;

    if (_user != null) {
      _userData = await _authService.getUserData();
    }

    notifyListeners();
  }

  // ==================== SIGN UP ====================
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    String? studentId,
    String? department,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final error = await _authService.signUp(
      name: name,
      email: email,
      password: password,
      role: role,
      studentId: studentId,
      department: department,
    );

    if (error != null) {
      _errorMessage = error;
      _setLoading(false);
      return false;
    }

    // Fetch user data after signup
    _user = _authService.currentUser;
    _userData = await _authService.getUserData();

    _setLoading(false);
    return true;
  }

  // ==================== LOGIN ====================
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final error = await _authService.login(
      email: email,
      password: password,
    );

    if (error != null) {
      _errorMessage = error;
      _setLoading(false);
      return false;
    }

    // Fetch user data after login
    _user = _authService.currentUser;
    _userData = await _authService.getUserData();

    _setLoading(false);
    return true;
  }

  // ==================== GOOGLE SIGN IN ====================
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;

    final error = await _authService.signInWithGoogle();

    if (error != null) {
      _errorMessage = error;
      _setLoading(false);
      return false;
    }

    // Fetch user data
    _user = _authService.currentUser;
    _userData = await _authService.getUserData();

    _setLoading(false);
    return true;
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();

    _user = null;
    _userData = null;
    _errorMessage = null;
    _setLoading(false);
  }

  // ==================== RESET PASSWORD ====================
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;

    final error = await _authService.resetPassword(email);

    if (error != null) {
      _errorMessage = error;
      _setLoading(false);
      return false;
    }

    _setLoading(false);
    return true;
  }

  // ==================== REFRESH USER DATA ====================
  Future<void> refreshUserData() async {
    if (_user != null) {
      _userData = await _authService.getUserData();
      notifyListeners();
    }
  }

  // ==================== CLEAR ERROR ====================
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== HELPER ====================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}