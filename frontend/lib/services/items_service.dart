import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'http_interceptor.dart';

class ItemsService {
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

  Future<List<Map<String, dynamic>>> getUserItems() async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.get(
        Uri.parse('$baseUrl/items/collected'),
        headers: headers,
      );
      
      print('Коллекция - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['items']);
      } else {
        print('Ошибка загрузки коллекции: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Ошибка при загрузке коллекции: $e');
      return [];
    }
  }

  Future<bool> placeItem(int itemId, double x, double y) async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.post(
        Uri.parse('$baseUrl/item-positions'),
        headers: headers,
        body: json.encode({
          'item_id': itemId,
          'x': x,
          'y': y,
        }),
      );
      
      print('Размещение предмета - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Предмет размещён успешно');
        return true;
      } else {
        print('Ошибка размещения: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Ошибка при размещении предмета: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPlacedItems() async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.get(
        Uri.parse('$baseUrl/item-positions'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['positions']);
      }
      return [];
    } catch (e) {
      print('Ошибка загрузки размещённых предметов: $e');
      return [];
    }
  }

  Future<bool> removePlacedItem(int positionId) async {
    try {
      final headers = await _getHeaders();
      final response = await HttpInterceptor.delete(
        Uri.parse('$baseUrl/item-positions/$positionId'),
        headers: headers,
      );
      
      print('Удаление размещённого предмета - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Предмет успешно убран с экрана');
        return true;
      } else {
        print('Ошибка удаления: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Ошибка при удалении предмета: $e');
      return false;
    }
  }
}