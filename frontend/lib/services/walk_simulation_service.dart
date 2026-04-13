import 'dart:math';

class WalkSimulationService {
  static const double EARTH_RADIUS = 6371000;
  
  double _currentLat = 55.751244;
  double _currentLng = 37.618423;
  double _speed = 0.5; // Уменьшена скорость: 0.5 м/сек (1.8 км/ч - медленная прогулка)
  
  List<Map<String, double>> _waypoints = [];
  DateTime? _lastUpdate;
  double _totalDistance = 0.0;
  
  void startSimulation() {
    _currentLat = 55.751244;
    _currentLng = 37.618423;
    _totalDistance = 0.0;
    _lastUpdate = DateTime.now();
    _generateWaypoints();
  }
  
  void _generateWaypoints() {
    _waypoints.clear();
    final random = Random();
    
    // Генерируем 2-3 точки (меньше для меньшего расстояния)
    final waypointsCount = random.nextInt(2) + 2;
    
    for (int i = 0; i < waypointsCount; i++) {
      // Очень маленькое смещение (~50-100 метров)
      final latOffset = (random.nextDouble() - 0.5) * 0.001;
      final lngOffset = (random.nextDouble() - 0.5) * 0.001;
      
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
    
    // Масштабируем: 1 реальная секунда = 1 минута (60 секунд)
    final simulatedSeconds = realSeconds * 60.0;
    
    // Рассчитываем пройденное расстояние за этот шаг (очень маленькое)
    final stepDistance = _speed * simulatedSeconds;
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