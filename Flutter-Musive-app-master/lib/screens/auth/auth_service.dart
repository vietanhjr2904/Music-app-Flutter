import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService {
  static String _hash(String pw) =>
      sha256.convert(utf8.encode(pw)).toString();

  static bool isLoggedIn() {
    return Hive.box('session').get('username') != null;
  }

  static String? currentUser() => Hive.box('session').get('username');

  static Future<String?> register(
      String username, String email, String password) async {
    final users = Hive.box('users');
    if (username.trim().isEmpty || password.length < 4) {
      return 'Tên đăng nhập trống hoặc mật khẩu < 4 ký tự';
    }
    if (users.containsKey(username)) {
      return 'Tên đăng nhập đã tồn tại';
    }
    await users.put(username, {
      'email': email,
      'password': _hash(password),
      'createdAt': DateTime.now().toIso8601String(),
    });
    await Hive.box('session').put('username', username);
    return null;
  }

  static Future<String?> login(String username, String password) async {
    final users = Hive.box('users');
    final u = users.get(username);
    if (u == null) return 'Tài khoản không tồn tại';
    if (u['password'] != _hash(password)) return 'Mật khẩu không đúng';
    await Hive.box('session').put('username', username);
    return null;
  }

  static Future<void> logout() async {
    await Hive.box('session').clear();
  }
}
