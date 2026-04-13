import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Хранилище для последних 2 координат
  final List<Position> _lastPositions = [];
  
  // Общее пройденное расстояние в метрах
  double _totalDistance = 0.0;
  
  // Флаг, идет ли прогулка
  bool _isWalking = false;
  
  // Таймер для сбора координат
  Timer? _locationTimer;
  
  // Последняя обработанная позиция (для избежания дубликатов)
  Position? _lastProcessedPosition;
  
  // Функция обратного вызова при обновлении расстояния
  Function(double distance)? onDistanceUpdated;
  Function(Position position)? onPositionUpdated;
  
  // Проверка и запрос разрешений
  Future<bool> requestPermissions() async {
    final status = await Permission.location.request();
    
    if (status.isGranted) {
      // Проверяем, включена ли служба геолокации
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }
      return true;
    }
    return false;
  }
  
  // Получить текущую позицию
  Future<Position?> getCurrentPosition() async {
    try {
      bool hasPermission = await requestPermissions();
      if (!hasPermission) return null;
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Ошибка получения позиции: $e');
      return null;
    }
  }
  
  // Рассчитать расстояние между двумя точками в метрах
  double _calculateDistance(Position pos1, Position pos2) {
    return Geolocator.distanceBetween(
      pos1.latitude, pos1.longitude,
      pos2.latitude, pos2.longitude,
    );
  }
  
  // Проверка, изменилась ли позиция (игнорируем маленькие изменения)
  bool _isPositionChanged(Position newPos, Position oldPos) {
    // Игнорируем изменения меньше 1 метра (шум GPS)
    double distance = _calculateDistance(newPos, oldPos);
    return distance > 1.0; // Изменилось больше чем на 1 метр
  }
  
  // Начать сбор координат
  void startTracking() {
    if (_isWalking) return;
    
    _isWalking = true;
    _totalDistance = 0.0;
    _lastPositions.clear();
    _lastProcessedPosition = null;
    
    // Первый сбор координат
    _collectLocation();
    
    // Запускаем таймер на каждые 3 секунды
    _locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isWalking) {
        _collectLocation();
      }
    });
  }
  
  // Сбор координат
  Future<void> _collectLocation() async {
    if (!_isWalking) return;
    
    Position? newPosition = await getCurrentPosition();
    if (newPosition == null) return;
    
    // Проверяем, изменилась ли позиция (игнорируем дубликаты и шум)
    if (_lastProcessedPosition != null) {
      if (!_isPositionChanged(newPosition, _lastProcessedPosition!)) {
        print('📍 Позиция не изменилась, пропускаем');
        return;
      }
    }
    
    print('📍 Новая позиция: ${newPosition.latitude.toStringAsFixed(6)}, ${newPosition.longitude.toStringAsFixed(6)}');
    
    // Обновляем последнюю обработанную позицию
    _lastProcessedPosition = newPosition;
    
    // Вызываем колбэк с новой позицией
    onPositionUpdated?.call(newPosition);
    
    // Добавляем новую позицию
    _lastPositions.add(newPosition);
    
    // Если у нас больше 2 позиций, удаляем самую старую
    while (_lastPositions.length > 2) {
      _lastPositions.removeAt(0);
    }
    
    // Если у нас есть 2 позиции, считаем расстояние между ними
    if (_lastPositions.length == 2) {
      double distance = _calculateDistance(_lastPositions[0], _lastPositions[1]);
      
      // Добавляем расстояние только если оно значительное (больше 1 метра)
      if (distance > 1.0) {
        _totalDistance += distance;
        print('➕ Добавлено расстояние: ${distance.toStringAsFixed(2)} м');
        print('📊 Общее расстояние: ${_totalDistance.toStringAsFixed(2)} м');
        
        // Вызываем колбэк с обновленным расстоянием
        onDistanceUpdated?.call(_totalDistance);
      } else {
        print('⚠️ Расстояние слишком маленькое, не добавляем: ${distance.toStringAsFixed(2)} м');
      }
    }
  }
  
  // Остановить сбор координат
  void stopTracking() {
    _isWalking = false;
    _locationTimer?.cancel();
    _locationTimer = null;
    print('📍 Отслеживание остановлено. Финальное расстояние: ${_totalDistance.toStringAsFixed(2)} м');
  }
  
  // Получить текущее общее расстояние
  double getTotalDistance() => _totalDistance;
  
  // Проверка, идет ли отслеживание
  bool get isTracking => _isWalking;
  
  // Сброс всех данных
  void reset() {
    _totalDistance = 0.0;
    _lastPositions.clear();
    _lastProcessedPosition = null;
  }
}