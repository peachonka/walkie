import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/http_interceptor.dart';

class AchievementsService {
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

  Future<List<Map<String, dynamic>>> getAchievementProgress() async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.get(
        Uri.parse('$baseUrl/achievements/progress'),
        headers: headers,
      );
      
      print('Achievements progress - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final achievements = data['achievements'] as List;
        return achievements.cast<Map<String, dynamic>>();
      } else {
        print('Ошибка загрузки достижений: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Ошибка при загрузке достижений: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllAchievements() async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.get(
        Uri.parse('$baseUrl/achievements'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final achievements = data['achievements'] as List;
        return achievements.cast<Map<String, dynamic>>();
      } else {
        print('Ошибка загрузки всех достижений: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Ошибка при загрузке всех достижений: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserAchievements() async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.get(
        Uri.parse('$baseUrl/achievements/user'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final achievements = data['achievements'] as List;
        return achievements.cast<Map<String, dynamic>>();
      } else {
        print('Ошибка загрузки полученных достижений: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Ошибка при загрузке полученных достижений: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAchievementTypes() async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.get(
        Uri.parse('$baseUrl/achievements/types'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final types = data['types'] as List;
        return types.cast<Map<String, dynamic>>();
      } else {
        print('Ошибка загрузки типов достижений: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Ошибка при загрузке типов достижений: $e');
      return [];
    }
  }
}