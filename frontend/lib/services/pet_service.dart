import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'http_interceptor.dart';

class PetService {
  static const String baseUrl = 'http://157.22.192.92:3000/api';

  // ============================================================
  // ВСПОМОГАТЕЛЬНОЕ
  // ============================================================

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      print('!!! [PetService] Токен ОТСУТСТВУЕТ в SharedPreferences');
    } else {
      final preview = token.length > 30 ? token.substring(0, 30) : token;
      print('=== [PetService] Токен: $preview... (длина: ${token.length})');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _previewBody(String body, {int maxLen = 400}) {
    if (body.length <= maxLen) return body;
    return '${body.substring(0, maxLen)}... [обрезано, всего ${body.length} символов]';
  }

  // ============================================================
  // МЕТОДЫ
  // ============================================================

  /// Проверить, есть ли у пользователя питомец
  Future<bool> hasPet() async {
    print('=== [PetService.hasPet] Начало');
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/pet';
      print('=== [PetService.hasPet] GET $url');

      final response = await HttpInterceptor.get(
        Uri.parse(url),
        headers: headers,
      );

      print('=== [PetService.hasPet] Status: ${response.statusCode}');
      print('=== [PetService.hasPet] Body: ${_previewBody(response.body)}');

      if (response.statusCode == 200) {
        print('=== [PetService.hasPet] Питомец найден');
        return true;
      } else if (response.statusCode == 404) {
        print('=== [PetService.hasPet] Питомец не найден (404)');
        return false;
      } else {
        print('=== [PetService.hasPet] Неожиданный статус: ${response.statusCode}');
        return false;
      }
    } catch (e, stackTrace) {
      print('!!! [PetService.hasPet] Исключение: $e');
      print('!!! [PetService.hasPet] StackTrace: $stackTrace');
      return false;
    }
  }

  /// Получить данные питомца
  Future<Map<String, dynamic>?> getPet() async {
    print('=== [PetService.getPet] Начало');
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/pet';
      print('=== [PetService.getPet] GET $url');

      final response = await HttpInterceptor.get(
        Uri.parse(url),
        headers: headers,
      );

      print('=== [PetService.getPet] Status: ${response.statusCode}');
      print('=== [PetService.getPet] Body: ${_previewBody(response.body)}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print('=== [PetService.getPet] Распарсенный ответ: $decoded');
        return decoded;
      }

      print('=== [PetService.getPet] Не 200, возвращаем null');
      return null;
    } catch (e, stackTrace) {
      print('!!! [PetService.getPet] Исключение: $e');
      print('!!! [PetService.getPet] StackTrace: $stackTrace');
      return null;
    }
  }

  /// Получить список доступных типов питомцев
  Future<List<Map<String, dynamic>>> getPetTypes() async {
    print('=== [PetService.getPetTypes] НАЧАЛО ЗАГРУЗКИ ТИПОВ ПИТОМЦЕВ');
    try {
      final headers = await _getHeaders();
      print('=== [PetService.getPetTypes] Заголовки: $headers');

      final url = '$baseUrl/pet/types';
      print('=== [PetService.getPetTypes] URL запроса: $url');

      final response = await HttpInterceptor.get(
        Uri.parse(url),
        headers: headers,
      );

      print('=== [PetService.getPetTypes] ---------- ОТВЕТ СЕРВЕРА ----------');
      print('=== [PetService.getPetTypes] Status: ${response.statusCode}');
      print('=== [PetService.getPetTypes] Headers: ${response.headers}');
      print('=== [PetService.getPetTypes] Body: ${_previewBody(response.body)}');
      print('=== [PetService.getPetTypes] -------------------------------');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['pets'] == null) {
          print('!!! [PetService.getPetTypes] В ответе нет ключа "pets". Ответ: $data');
          return [];
        }

        final pets = List<Map<String, dynamic>>.from(data['pets']);
        print('=== [PetService.getPetTypes] Распарсено питомцев: ${pets.length}');
        for (var pet in pets) {
          print(
              '=== [PetService.getPetTypes] Питомец: id=${pet['id']} (${pet['id'].runtimeType}), type=${pet['type']}, avatar=${pet['avatar']}');
        }
        return pets;
      }

      print('!!! [PetService.getPetTypes] Статус не 200 — возвращаем пустой список');
      return [];
    } catch (e, stackTrace) {
      print('!!! [PetService.getPetTypes] Исключение: $e');
      print('!!! [PetService.getPetTypes] StackTrace: $stackTrace');
      return [];
    }
  }

  /// Создать питомца.
  /// petId теперь String (UUID с бэка).
  Future<bool> createPet(String petId, String name) async {
    print('=== [PetService.createPet] Начало (petId=$petId, name=$name)');
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/pet';
      final body = json.encode({
        'petId': petId,
        'name': name,
      });

      print('=== [PetService.createPet] POST $url');
      print('=== [PetService.createPet] Body: $body');

      final response = await HttpInterceptor.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('=== [PetService.createPet] Status: ${response.statusCode}');
      print('=== [PetService.createPet] Body: ${_previewBody(response.body)}');

      if (response.statusCode == 201) {
        print('=== [PetService.createPet] Питомец создан успешно');
        return true;
      }

      print('!!! [PetService.createPet] Ошибка создания (${response.statusCode})');
      return false;
    } catch (e, stackTrace) {
      print('!!! [PetService.createPet] Исключение: $e');
      print('!!! [PetService.createPet] StackTrace: $stackTrace');
      return false;
    }
  }

  /// Обновить имя питомца
  Future<bool> updatePetName(String newName) async {
    print('=== [PetService.updatePetName] Начало (newName=$newName)');
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/pet/name';
      final body = json.encode({'name': newName});

      print('=== [PetService.updatePetName] PUT $url');
      print('=== [PetService.updatePetName] Body: $body');

      final response = await HttpInterceptor.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('=== [PetService.updatePetName] Status: ${response.statusCode}');
      print('=== [PetService.updatePetName] Body: ${_previewBody(response.body)}');

      if (response.statusCode == 200) {
        print('=== [PetService.updatePetName] Имя обновлено успешно');
        return true;
      }

      print('!!! [PetService.updatePetName] Ошибка (${response.statusCode})');
      return false;
    } catch (e, stackTrace) {
      print('!!! [PetService.updatePetName] Исключение: $e');
      print('!!! [PetService.updatePetName] StackTrace: $stackTrace');
      return false;
    }
  }
}