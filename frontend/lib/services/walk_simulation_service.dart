import 'dart:math';

class WalkSimulationService {
  static const double EARTH_RADIUS = 6371000;
  
  double _currentLat = 55.751244;
  double _currentLng = 37.618423;
  
  // Настройки скорости
  // speedKmh - желаемая скорость в км/ч в игровом мире
  // Например: 5 км/ч - медленная прогулка, 10 км/ч - быстрая, 15 км/ч - бег
  double _speedKmh = 5.0; // 10 км/ч - средняя скорость
  
  // Рассчитываем реальную скорость в м/сек с учётом масштабирования
  double get _speedInMetersPerSecond {
    // Переводим км/ч в м/с: км/ч * 1000 / 3600 = м/с
    final realSpeedMs = _speedKmh * 1000 / 3600;
    // Умножаем на 60, потому что 1 реальная секунда = 1 игровая минута (60 секунд)
    return realSpeedMs * 60;
  }
  
  List<Map<String, double>> _waypoints = [];
  DateTime? _lastUpdate;
  double _totalDistance = 0.0;
  
  void startSimulation({double? speedKmh}) {
    if (speedKmh != null) {
      _speedKmh = speedKmh;
    }
    _currentLat = 55.751244;
    _currentLng = 37.618423;
    _totalDistance = 0.0;
    _lastUpdate = DateTime.now();
    _generateWaypoints();
  }
  
  void _generateWaypoints() {
    _waypoints.clear();
    final random = Random();
    
    // Генерируем 5-10 точек для разнообразия маршрута
    final waypointsCount = random.nextInt(6) + 5;
    
    for (int i = 0; i < waypointsCount; i++) {
      // Смещение до 3 км (0.03 градуса ≈ 3 км)
      final latOffset = (random.nextDouble() - 0.5) * 0.03;
      final lngOffset = (random.nextDouble() - 0.5) * 0.03;
      
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
    
    final realSeconds = now.difference(_lastUpdate!).inSeconds;
    if (realSeconds == 0) {
      return {'lat': _currentLat, 'lng': _currentLng};
    }
    
    // Рассчитываем пройденное расстояние
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
  
  double getCurrentDistance() {
    return _totalDistance;
  }
  
  void reset() {
    _currentLat = 55.751244;
    _currentLng = 37.618423;
    _totalDistance = 0.0;
    _waypoints.clear();
    _lastUpdate = null;
  }
}