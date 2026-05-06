import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://localhost/api";

  /// ================= REGISTER =================
  static Future<String?> register(
      String username,
      String email,
      String password,
      ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register.php"),
        body: {
          "username": username,
          "email": email,
          "password": password,
        },
      );

      if (response.statusCode != 200) {
        return "Máy chủ lỗi: ${response.statusCode}";
      }

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        await _saveSession(
          username: _readUsername(data) ?? username,
          email: _readEmail(data) ?? email,
        );
        return null;
      }

      return data['message']?.toString() ?? "Đăng ký thất bại";
    } catch (e) {
      return "Không thể kết nối đến máy chủ";
    }
  }

  /// ================= LOGIN =================
  static Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: {
          "email": email,
          "password": password,
        },
      );

      if (response.statusCode != 200) {
        return "Máy chủ lỗi: ${response.statusCode}";
      }

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        await _saveSession(
          username: _readUsername(data) ?? email,
          email: _readEmail(data) ?? email,
        );
        return null;
      }

      return data['message']?.toString() ?? "Đăng nhập thất bại";
    } catch (e) {
      return "Không thể kết nối đến máy chủ";
    }
  }

  static String? _readUsername(Map<String, dynamic> data) {
    if (data['username'] != null) return data['username'].toString();

    final user = data['user'];
    if (user is Map && user['username'] != null) {
      return user['username'].toString();
    }

    return null;
  }

  static String? _readEmail(Map<String, dynamic> data) {
    if (data['email'] != null) return data['email'].toString();

    final user = data['user'];
    if (user is Map && user['email'] != null) {
      return user['email'].toString();
    }

    return null;
  }

  static Future<void> _saveSession({
    required String username,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLogin", true);
    await prefs.setString("username", username);
    await prefs.setString("email", email);

    final session = Hive.box('session');
    await session.put('isLogin', true);
    await session.put('username', username);
    await session.put('email', email);
  }

  /// ================= CHECK LOGIN =================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsLoggedIn = prefs.getBool("isLogin") ?? false;
    if (prefsLoggedIn) return true;

    if (!Hive.isBoxOpen('session')) return false;
    return Hive.box('session').get('isLogin') == true;
  }

  /// ================= LOGOUT =================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("isLogin");
    await prefs.remove("username");
    await prefs.remove("email");

    if (Hive.isBoxOpen('session')) {
      await Hive.box('session').clear();
    }
  }
}