import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'http_interceptor.dart';

class WalkService {
  static const String baseUrl = 'https://walkie-v9i6.onrender.com/api';
  static const String _activeWalkIdKey = 'active_walk_id';
  static const String _activeWalkStartTimeKey = 'active_walk_start_time';
  
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

  // Сохранить активную прогулку в локальное хранилище
  Future<void> saveActiveWalk(int walkId, DateTime startTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_activeWalkIdKey, walkId);
    await prefs.setString(_activeWalkStartTimeKey, startTime.toIso8601String());
    print('Активная прогулка сохранена: ID=$walkId, время=$startTime');
  }

  // Получить сохранённый ID активной прогулки
  Future<int?> getSavedActiveWalkId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_activeWalkIdKey);
  }

  // Получить сохранённое время начала прогулки
  Future<DateTime?> getSavedActiveWalkStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_activeWalkStartTimeKey);
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }

  // Очистить сохранённую активную прогулку
  Future<void> clearSavedActiveWalk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeWalkIdKey);
    await prefs.remove(_activeWalkStartTimeKey);
    print('Сохранённая активная прогулка очищена');
  }

  // Проверить, есть ли сохранённая активная прогулка
  Future<bool> hasSavedActiveWalk() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_activeWalkIdKey);
  }

  // Начать прогулку (с сохранением)
  Future<Map<String, dynamic>?> startWalk() async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.post(
        Uri.parse('$baseUrl/walks/start'),
        headers: headers,
      );
      
      print('Начало прогулки - Status: ${response.statusCode}');
      print('Ответ: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final walkId = data['walk_id'];
        final startTime = DateTime.parse(data['start_time']);
        
        // Сохраняем активную прогулку
        await saveActiveWalk(walkId, startTime);
        
        print('=== ПРОГУЛКА НАЧАТА ===');
        print('ID прогулки: $walkId');
        print('Время начала: $startTime');
        print('========================');
        
        return data;
      } else if (response.statusCode == 409) {
        print('Обнаружена активная прогулка на сервере');
        final activeWalk = await getActiveWalkFromServer();
        if (activeWalk != null && activeWalk['walk_id'] != null) {
          final walkId = activeWalk['walk_id'];
          final startTime = DateTime.parse(activeWalk['start_time']);
          await saveActiveWalk(walkId, startTime);
          
          print('=== ВОССТАНОВЛЕНА АКТИВНАЯ ПРОГУЛКА ===');
          print('ID прогулки: $walkId');
          print('Время начала: $startTime');
          print('=======================================');
          
          return activeWalk;
        }
        return null;
      } else {
        print('Ошибка начала прогулки: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Ошибка при начале прогулки: $e');
      return null;
    }
  }

  // Получить активную прогулку с сервера
  Future<Map<String, dynamic>?> getActiveWalkFromServer() async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.get(
        Uri.parse('$baseUrl/walks/active'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Ошибка получения активной прогулки: $e');
      return null;
    }
  }

  // Завершить прогулку (с очисткой хранилища)
  Future<Map<String, dynamic>?> endWalk(int walkId, double distance, int duration) async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.post(
        Uri.parse('$baseUrl/walks/$walkId/end'),
        headers: headers,
        body: json.encode({
          'distance': distance,
          'duration': duration,
        }),
      );
      
      print('Завершение прогулки - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // Очищаем сохранённую активную прогулку
        await clearSavedActiveWalk();
        
        final data = json.decode(response.body);
        print('=== ПРОГУЛКА ЗАВЕРШЕНА ===');
        print('ID прогулки: $walkId');
        print('Расстояние: ${distance}m');
        print('Длительность: ${duration}s');
        print('==========================');
        
        return data;
      } else {
        print('Ошибка завершения прогулки: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Ошибка при завершении прогулки: $e');
      return null;
    }
  }

  // Восстановить активную прогулку при запуске приложения
  Future<int?> restoreActiveWalkIfNeeded() async {
    final savedId = await getSavedActiveWalkId();
    if (savedId != null) {
      print('Найдена сохранённая активная прогулка: ID=$savedId');
      
      final activeWalk = await getActiveWalkFromServer();
      if (activeWalk != null && activeWalk['walk_id'] == savedId) {
        print('Активная прогулка подтверждена на сервере');
        return savedId;
      } else {
        print('Сохранённая прогулка не найдена на сервере, очищаем');
        await clearSavedActiveWalk();
        return null;
      }
    }
    return null;
  }

  // Проверить наличие активной прогулки
  Future<bool> hasActiveWalk() async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.get(
        Uri.parse('$baseUrl/walks/active'),
        headers: headers,
      );
      
      print('Проверка активной прогулки - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['has_active'] == true;
      }
      return false;
    } catch (e) {
      print('Ошибка проверки активной прогулки: $e');
      return false;
    }
  }

  // Получить активную прогулку
  Future<Map<String, dynamic>?> getActiveWalk() async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.get(
        Uri.parse('$baseUrl/walks/active'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Ошибка получения активной прогулки: $e');
      return null;
    }
  }

  // Принудительно завершить активную прогулку
  Future<bool> forceEndActiveWalk() async {
    try {
      final activeWalk = await getActiveWalk();
      if (activeWalk != null && activeWalk['walk_id'] != null) {
        final walkId = activeWalk['walk_id'];
        print('Найдена активная прогулка ID: $walkId, принудительно завершаем');
        
        final result = await endWalk(walkId, 0, 0);
        return result != null;
      }
      return false;
    } catch (e) {
      print('Ошибка принудительного завершения прогулки: $e');
      return false;
    }
  }

  // Получить историю прогулок
  Future<List<Map<String, dynamic>>> getWalkHistory({int limit = 20}) async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.get(
        Uri.parse('$baseUrl/walks/history?limit=$limit'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['walks']);
      }
      return [];
    } catch (e) {
      print('Ошибка получения истории прогулок: $e');
      return [];
    }
  }
}