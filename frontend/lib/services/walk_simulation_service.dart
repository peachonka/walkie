import 'dart:math';

class WalkSimulationService {
  static const double EARTH_RADIUS = 6371000;
  
  double _currentLat = 55.751244;
  double _currentLng = 37.618423;
  
  // Настройки скорости (реальная скорость в км/ч)
  double _speedKmh = 5.0; // 5 км/ч - реальная скорость прогулки
  
  // Реальная скорость в м/сек (БЕЗ УМНОЖЕНИЯ НА 60)
  double get _speedInMetersPerSecond {
    // км/ч → м/с: делим на 3.6
    return _speedKmh / 3.6;
  }
  
  List<Map<String, double>> _waypoints = [];
  DateTime? _lastUpdate;
  double _totalDistance = 0.0;
  int _totalDuration = 0; // Добавляем счетчик времени в секундах
  
  void startSimulation({double? speedKmh}) {
    if (speedKmh != null) {
      _speedKmh = speedKmh;
    }
    _currentLat = 55.751244;
    _currentLng = 37.618423;
    _totalDistance = 0.0;
    _totalDuration = 0; // Сбрасываем время
    _lastUpdate = DateTime.now();
    _generateWaypoints();
  }
  
  void _generateWaypoints() {
    _waypoints.clear();
    final random = Random();
    
    // Генерируем 10-20 точек для более плавного маршрута
    final waypointsCount = random.nextInt(11) + 10;
    
    for (int i = 0; i < waypointsCount; i++) {
      // Смещение до 5 км (0.05 градуса ≈ 5 км)
      final latOffset = (random.nextDouble() - 0.5) * 0.05;
      final lngOffset = (random.nextDouble() - 0.5) * 0.05;
      
      _waypoints.add({
        'lat': 55.751244 + latOffset,
        'lng': 37.618423 + lngOffset,
      });
    }
  }
  
  Map<String, double> updatePosition() {
    final now = DateTime.now();
    if (_lastUpdate == null) {
      _lastUpdate = now;
      return {'lat': _currentLat, 'lng': _currentLng};
    }
    
    // Реальные прошедшие секунды
    final realSeconds = now.difference(_lastUpdate!).inSeconds;
    if (realSeconds == 0) {
      return {'lat': _currentLat, 'lng': _currentLng};
    }
    
    // Увеличиваем общую длительность
    _totalDuration += realSeconds;
    
    // Рассчитываем пройденное расстояние за реальные секунды
    final stepDistance = _speedInMetersPerSecond * realSeconds;
    _totalDistance += stepDistance;
    
    if (_waypoints.isNotEmpty) {
      final target = _waypoints.first;
      final targetLat = target['lat']!;
      final targetLng = target['lng']!;
      
      final distanceToTarget = _calculateDistance(
        _currentLat, _currentLng,
        targetLat, targetLng
      );
      
      if (distanceToTarget <= stepDistance) {
        _currentLat = targetLat;
        _currentLng = targetLng;
        _waypoints.removeAt(0);
        
        if (_waypoints.isEmpty) {
          _generateWaypoints();
        }
      } else if (distanceToTarget > 0) {
        final fraction = stepDistance / distanceToTarget;
        _currentLat += (targetLat - _currentLat) * fraction;
        _currentLng += (targetLng - _currentLng) * fraction;
      }
    } else {
      _generateWaypoints();
    }
    
    _lastUpdate = now;
    
    return {'lat': _currentLat, 'lng': _currentLng};
  }
  
  double getCurrentDistance() {
    return _totalDistance;
  }
  
  int getCurrentDuration() {
    return _totalDuration; // Возвращаем реальное время в секундах
  }
  
  void reset() {
    _currentLat = 55.751244;
    _currentLng = 37.618423;
    _totalDistance = 0.0;
    _totalDuration = 0;
    _waypoints.clear();
    _lastUpdate = null;
  }
  
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371000;
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lng2 - lng1) * pi / 180;
    
    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
              cos(phi1) * cos(phi2) *
              sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return R * c;
  }
}