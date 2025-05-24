import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance/models/employee.dart';
import 'package:attendance/services/mock_api_service.dart';

class AuthProvider with ChangeNotifier {
  Employee? _currentEmployee;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  Employee? get currentEmployee => _currentEmployee;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  final MockApiService _apiService = MockApiService();

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final savedEmployeeJson = prefs.getString('currentEmployee');

    if (isLoggedIn && savedEmployeeJson != null) {
      try {
        // Simulate checking token validity with API
        final result = await _apiService.validateToken();
        if (result) {
          // Load saved employee data
          // _currentEmployee = await _apiService.getCurrentEmployeeInfo();
          _currentEmployee = Employee.fromJson(jsonDecode(savedEmployeeJson));

          _isAuthenticated = true;
        } else {
          _isAuthenticated = false;
          // Clear stored data if token is invalid
          await prefs.remove('employeeId');
          await prefs.remove('currentEmployee');
        }
      } catch (e) {
        _error = 'Session expired, please login again';
        _isAuthenticated = false;
      }
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  Future<bool> login(String employeeCode, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulated API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock login logic (would be real API call in production)
      final loginResult = await _apiService.login(employeeCode, password);

      if (loginResult != null) {
        _currentEmployee = loginResult;
        _isAuthenticated = true;

        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('employeeCode', employeeCode);
        await prefs.setString(
            'currentEmployee', jsonEncode(loginResult.toJson()));
        await prefs.setString(
            'currentEmployee', jsonEncode(_currentEmployee!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid credentials';
        _isLoading = false;
        _isAuthenticated = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call to logout
      await Future.delayed(const Duration(milliseconds: 500));

      // Clear stored data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('employeeId');
      await prefs.clear(); // remove all saved login data

      _currentEmployee = null;
      _isAuthenticated = false;
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
