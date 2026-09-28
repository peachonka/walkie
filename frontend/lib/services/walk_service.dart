import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'http_interceptor.dart';

class WalkService {
  static const String baseUrl = 'http://157.22.192.92:3000/api';
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

  // ============================================================
  // ЛОКАЛЬНОЕ ХРАНИЛИЩЕ АКТИВНОЙ ПРОГУЛКИ
  // ============================================================

  Future<void> saveActiveWalk(String walkId, DateTime startTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeWalkIdKey, walkId);
    await prefs.setString(_activeWalkStartTimeKey, startTime.toIso8601String());
    print('Активная прогулка сохранена: ID=$walkId, время=$startTime');
  }

  Future<String?> getSavedActiveWalkId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeWalkIdKey);
  }

  Future<DateTime?> getSavedActiveWalkStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_activeWalkStartTimeKey);
    if (timeStr != null) {
      try {
        return DateTime.parse(timeStr);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearSavedActiveWalk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeWalkIdKey);
    await prefs.remove(_activeWalkStartTimeKey);
    print('Сохранённая активная прогулка очищена');
  }

  Future<bool> hasSavedActiveWalk() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_activeWalkIdKey);
  }

  // ============================================================
  // START WALK — с восстановлением по 409
  // ============================================================

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

        final walkId = data['walk_id'].toString();

        DateTime startTime;
        try {
          startTime = DateTime.parse(data['start_time']);
        } catch (_) {
          startTime = DateTime.now();
        }

        await saveActiveWalk(walkId, startTime);

        print('=== ПРОГУЛКА НАЧАТА ===');
        print('ID прогулки: $walkId');
        print('Время начала: $startTime');
        print('========================');

        return {
          'walk_id': walkId,
          'start_time': startTime.toIso8601String(),
        };
      } else if (response.statusCode == 409) {
        // Активная прогулка уже есть на сервере
        print('Обнаружена активная прогулка на сервере (409)');

        Map<String, dynamic> data = {};
        try {
          data = json.decode(response.body) as Map<String, dynamic>;
        } catch (e) {
          print('!!! Не удалось распарсить тело 409-ответа: $e');
        }

        // walkId приходит прямо в теле 409-ответа: {"error":"...","walkId":"2"}
        final walkId = data['walkId']?.toString();

        if (walkId == null) {
          print('!!! В 409-ответе нет walkId — не можем восстановить прогулку');
          print('!!! Тело: ${response.body}');
          return null;
        }

        // Пытаемся узнать start_time через /walks/active (если роут есть),
        // иначе — используем текущее время как fallback
        DateTime startTime = DateTime.now();
        try {
          final activeWalk = await getActiveWalkFromServer();
          if (activeWalk != null && activeWalk['start_time'] != null) {
            startTime = DateTime.parse(activeWalk['start_time']);
            print('start_time получен с /walks/active: $startTime');
          } else {
            print('Fallback: используем текущее время как start_time');
          }
        } catch (e) {
          print('Не удалось получить /walks/active: $e. Используем fallback.');
        }

        await saveActiveWalk(walkId, startTime);

        print('=== ВОССТАНОВЛЕНА АКТИВНАЯ ПРОГУЛКА ===');
        print('ID прогулки: $walkId');
        print('Время начала: $startTime');
        print('=======================================');

        return {
          'walk_id': walkId,
          'start_time': startTime.toIso8601String(),
        };
      } else {
        print('Ошибка начала прогулки: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Ошибка при начале прогулки: $e');
      print('StackTrace: $stackTrace');
      return null;
    }
  }

  // ============================================================
  // GET ACTIVE WALK FROM SERVER (безопасный — если роута нет, вернёт null)
  // ============================================================

  Future<Map<String, dynamic>?> getActiveWalkFromServer() async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.get(
        Uri.parse('$baseUrl/walks/active'),
        headers: headers,
      );

      print('getActiveWalkFromServer - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      // Роут /walks/active может отсутствовать на бэке — это не критично
      print('getActiveWalkFromServer: роут вернул ${response.statusCode}');
      return null;
    } catch (e) {
      print('Ошибка получения активной прогулки с сервера: $e');
      return null;
    }
  }

  // ============================================================
  // END WALK
  // ============================================================

  Future<Map<String, dynamic>?> endWalk(
      String walkId, double distance, int duration) async {
    try {
      final headers = await _getHeaders();

      const double avgStepLength = 0.75;
      int steps = (distance / avgStepLength).round();

      final response = await HttpInterceptor.post(
        Uri.parse('$baseUrl/walks/$walkId/end'),
        headers: headers,
        body: json.encode({
          'distance': distance,
          'duration': duration,
          'steps': steps,
        }),
      );

      print('Завершение прогулки - Status: ${response.statusCode}');
      print('Тело: ${response.body}');

      if (response.statusCode == 200) {
        await clearSavedActiveWalk();

        final data = json.decode(response.body);
        print('=== ПРОГУЛКА ЗАВЕРШЕНА ===');
        print('ID прогулки: $walkId');
        print('Расстояние: ${distance}m');
        print('Длительность: ${duration}s');
        print('Шаги: $steps');
        print('==========================');

        return data;
      } else {
        print('Ошибка завершения прогулки: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Ошибка при завершении прогулки: $e');
      print('StackTrace: $stackTrace');
      return null;
    }
  }

  // ============================================================
  // ВОССТАНОВЛЕНИЕ ПРИ ЗАПУСКЕ
  // ============================================================

  /// Восстанавливает активную прогулку при старте приложения.
  /// Работает даже если на бэке нет роута /walks/active:
  /// в этом случае доверяем локально сохранённому walkId.
  Future<String?> restoreActiveWalkIfNeeded() async {
    final savedId = await getSavedActiveWalkId();

    if (savedId == null) {
      print('Сохранённой активной прогулки нет');
      return null;
    }

    print('Найдена сохранённая активная прогулка: ID=$savedId');

    // Пробуем подтвердить на сервере (если роут есть)
    final activeWalk = await getActiveWalkFromServer();

    if (activeWalk == null) {
      // Роут /walks/active отсутствует или вернул ошибку.
      // Доверяем локальным данным — пользователь сможет завершить прогулку
      // через WalkScreen (POST /walks/:id/end работает всегда).
      print('Не удалось проверить прогулку на сервере. Доверяем локальному ID.');
      return savedId;
    }

    final serverId = activeWalk['walk_id']?.toString();

    if (serverId == savedId) {
      print('Активная прогулка подтверждена на сервере');
      return savedId;
    }

    if (serverId == null) {
      print('На сервере нет активной прогулки. Очищаем локальную.');
      await clearSavedActiveWalk();
      return null;
    }

    // На сервере активна другая прогулка — берём её
    print('На сервере другая активная прогулка: $serverId. Переключаемся на неё.');
    final startTimeStr = activeWalk['start_time'];
    DateTime startTime;
    try {
      startTime = startTimeStr != null
          ? DateTime.parse(startTimeStr)
          : DateTime.now();
    } catch (_) {
      startTime = DateTime.now();
    }
    await saveActiveWalk(serverId, startTime);
    return serverId;
  }

  // ============================================================
  // ВСПОМОГАТЕЛЬНОЕ
  // ============================================================

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

  Future<Map<String, dynamic>?> getActiveWalk() async {
    return getActiveWalkFromServer();
  }

  Future<bool> forceEndActiveWalk() async {
    try {
      final activeWalk = await getActiveWalk();
      if (activeWalk != null && activeWalk['walk_id'] != null) {
        final walkId = activeWalk['walk_id'].toString();
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