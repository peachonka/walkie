import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/http_interceptor.dart';

class StatsService {
  static const String baseUrl = 'https://walkie-v9i6.onrender.com/api';
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.get(
        Uri.parse('$baseUrl/stats'),
        headers: headers,
      );
      
      print('Статистика - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'total_distance_km': data['total_distance_km'] ?? 0,
          'total_duration_hours': data['total_duration_hours'] ?? 0,
          'total_walks': data['total_walks'] ?? 0,
          'total_steps': data['total_steps'] ?? 0,
          'total_items_collected': data['total_items_collected'] ?? 0,
          'first_walk_date': data['first_walk_date'] ?? 'Нет прогулок',
          'last_walk_date': data['last_walk_date'] ?? 'Нет прогулок',
        };
      } else {
        print('Ошибка загрузки статистики: ${response.body}');
        return _getEmptyStats();
      }
    } catch (e) {
      print('Ошибка при загрузке статистики: $e');
      return _getEmptyStats();
    }
  }

  Map<String, dynamic> _getEmptyStats() {
    return {
      'total_distance_km': 0,
      'total_duration_hours': 0,
      'total_walks': 0,
      'total_steps': 0,
      'total_items_collected': 0,
      'first_walk_date': 'Нет прогулок',
      'last_walk_date': 'Нет прогулок',
    };
  }
}