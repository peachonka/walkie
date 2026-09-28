import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://157.22.192.92:3000/api';

  // ============================================================
  // ТОКЕН
  // ============================================================

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('-- Токен сохранён в локальное хранилище');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<bool> isAuthorized() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('pet_name');
    await prefs.remove('user_id');
    await prefs.remove('active_walk_id');
    await prefs.remove('active_walk_start_time');
    print('-- Локальные данные пользователя очищены');
  }

  // ============================================================
  // РЕГИСТРАЦИЯ / АВТОРИЗАЦИЯ
  // ============================================================

  /// Регистрация. Возвращает null при успехе, иначе — текст ошибки.
  Future<String?> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('-- Регистрация - Status: ${response.statusCode}');
      print('-- Response: ${response.body}');

      if (response.statusCode == 201) {
        return null; // успех
      }

      return _extractError(response.body, 'Ошибка регистрации');
    } catch (e) {
      print('-- Ошибка регистрации: $e');
      return 'Ошибка сети: $e';
    }
  }

  /// Вход. Возвращает null при успехе, иначе — текст ошибки.
  /// При успехе токен сохраняется в SharedPreferences.
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('-- Авторизация - Status: ${response.statusCode}');
      print('-- Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        if (token == null || token.toString().isEmpty) {
          return 'Токен не получен от сервера';
        }
        await saveToken(token);
        return null; // успех
      }

      return _extractError(response.body, 'Ошибка авторизации');
    } catch (e) {
      print('-- Ошибка авторизации: $e');
      return 'Ошибка сети: $e';
    }
  }

  /// Регистрация + автоматический вход (т.к. /register не возвращает токен).
  /// Возвращает null при успехе, иначе — текст ошибки.
  Future<String?> registerAndLogin(String email, String password) async {
    final registerError = await register(email, password);
    if (registerError != null) return registerError;

    // После успешной регистрации сразу логинимся, чтобы получить токен
    return await login(email, password);
  }

  // ============================================================
  // ВСПОМОГАТЕЛЬНОЕ
  // ============================================================

  String _extractError(String body, String fallback) {
    try {
      final data = json.decode(body);
      return data['error']?.toString() ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}