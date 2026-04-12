import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'http_interceptor.dart';

class PetService {
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

  Future<bool> hasPet() async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.get(
        Uri.parse('$baseUrl/pet'),
        headers: headers,
      );
      
      print('-- Проверка питомца - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('-- Питомец найден');
        return true;
      } else if (response.statusCode == 404) {
        print('-- Питомец не найден');
        return false;
      } else {
        print('-- Ошибка: ${response.body}');
        return false;
      }
    } catch (e) {
      print('-- Ошибка при проверке питомца: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getPet() async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.get(
        Uri.parse('$baseUrl/pet'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('-- Ошибка получения питомца: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getPetTypes() async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.get(
        Uri.parse('$baseUrl/pet/types'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['pets']);
      }
      return [];
    } catch (e) {
      print('-- Ошибка получения типов питомцев: $e');
      return [];
    }
  }

  Future<bool> createPet(int petId, String name) async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.post(
        Uri.parse('$baseUrl/pet'),
        headers: headers,
        body: json.encode({
          'petId': petId,
          'name': name,
        }),
      );
      
      print('-- Создание питомца - Status: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        print('-- Питомец создан успешно');
        return true;
      } else {
        print('-- Ошибка создания: ${response.body}');
        return false;
      }
    } catch (e) {
      print('-- Ошибка при создании питомца: $e');
      return false;
    }
  }

  Future<bool> updatePetName(String newName) async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.put(
        Uri.parse('$baseUrl/pet/name'),
        headers: headers,
        body: json.encode({
          'name': newName,
        }),
      );
      
      print('-- Обновление имени питомца - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('-- Имя питомца обновлено успешно');
        return true;
      } else {
        print('-- Ошибка обновления имени: ${response.body}');
        return false;
      }
    } catch (e) {
      print('-- Ошибка при обновлении имени питомца: $e');
      return false;
    }
  }
}