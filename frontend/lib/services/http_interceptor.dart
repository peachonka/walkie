import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../screens/auth_screen.dart';
import 'auth_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class HttpInterceptor {
  static final AuthService _authService = AuthService();

  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 401) {
      await _handleUnauthorized();
    }
    return response;
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 401) {
      await _handleUnauthorized();
    }
    return response;
  }

  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await http.put(url, headers: headers, body: body);
    if (response.statusCode == 401) {
      await _handleUnauthorized();
    }
    return response;
  }

  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final response = await http.delete(url, headers: headers);
    if (response.statusCode == 401) {
      await _handleUnauthorized();
    }
    return response;
  }

  static Future<void> _handleUnauthorized() async {
    print('-- Ошибка 401 - Токен истёк, выполняем выход');

    await _authService.logout();

    if (navigatorKey.currentContext != null) {
      print('-- Перенаправление на экран авторизации');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
            (route) => false,
          );
        }
      });
    } else {
      print('-- Не удалось получить контекст для навигации');
    }
  }
}