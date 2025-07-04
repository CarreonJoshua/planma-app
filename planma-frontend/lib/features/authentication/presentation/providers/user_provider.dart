import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:planma_app/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // User Data
  String? _accessToken;
  String? _refreshToken;
  String? _studentId;

  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;
  String? get accessToken => _accessToken;

  // Base API URL - adjust this to match your backend URL
  late final String _baseApiUrl;

  // Constructor to properly initialize the base URL
  UserProvider() {
    // Remove trailing slash if present in API_URL
    String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseApiUrl = '$baseUrl/api';
  }

  // Initialize provider by checking authentication status
  Future<void> init() async {
    await checkAuthentication();
  }

  // Check if user is authenticated
  Future<bool> checkAuthentication() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access');
      _refreshToken = prefs.getString('refresh');
      _studentId = prefs.getString('student_id');

      // If no tokens and student_id are present, user is not authenticated
      if (_accessToken == null && _refreshToken == null && _studentId == null) {
        _isAuthenticated = false;
        notifyListeners();
        return false;
      }

      // Get user data from shared preferences
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        _userData = jsonDecode(userDataString);
      }
      
      await fetchUserData();

      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error checking authentication: $e');
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch user data from API
  Future<void> fetchUserData() async {
    if (_accessToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$_baseApiUrl/djoser/users/me/'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _userData = jsonDecode(response.body);

        // Save user data to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(_userData));
      } else if (response.statusCode == 401) {
        // Try to refresh token and retry once
        final refreshed = await refreshToken();
        if (refreshed) {
          return await fetchUserData(); // retry once
        } else {
          await logout(); // optional
        }
      } else {
        print('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Log in user
  Future<bool> login(String email, String password) async {
    print(_baseApiUrl);
    try {
      final response = await http.post(
        Uri.parse('$_baseApiUrl/auth/jwt/create/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];
        _refreshToken = data['refresh'];
        _studentId = data['student_id'];

        // Save tokens to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access', _accessToken!);
        await prefs.setString('refresh', _refreshToken!);
        await prefs.setString('student_id', _studentId!);

        // Fetch user data
        await fetchUserData();

        // Initialize FCM and send token to Django
        await FCMService.initFCM(_accessToken!);

        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        print('Login failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  // Log out user
  Future<void> logout() async {
    try {
      // Clear tokens and user data
      _accessToken = null;
      _refreshToken = null;
      _userData = null;
      _isAuthenticated = false;

      // Remove data from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('access');
      await prefs.remove('refresh');
      await prefs.remove('user_data');
      await prefs.remove('student_id'); // Also remove student_id

      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Register a new user
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseApiUrl/auth/users/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        // Registration successful, now log in the user automatically
        return await login(email, password);
      } else {
        print('Registration failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseApiUrl/auth/jwt/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh': _refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];

        // Save new access token to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access', _accessToken!);

        return true;
      } else {
        print('Token refresh failed: ${response.statusCode}');
        // If refresh token is invalid, log out user
        if (response.statusCode == 401) {
          await logout();
        }
        return false;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }
}
