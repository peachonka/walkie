import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_theme.dart';
import '../services/walk_service.dart';
import '../services/location_service.dart';
import '../widgets/walk/walk_result_dialog.dart';

class WalkScreen extends StatefulWidget {
  final int walkId;
  final Function(Map<String, dynamic> result) onWalkEnd;

  const WalkScreen({
    super.key,
    required this.walkId,
    required this.onWalkEnd,
  });

  @override
  State<WalkScreen> createState() => _WalkScreenState();
}

class _WalkScreenState extends State<WalkScreen> {
  final WalkService _walkService = WalkService();
  final LocationService _locationService = LocationService();
  
  static const double _timeMultiplier = 20.0;
  
  final MapController _mapController = MapController();
  
  LatLng _currentPosition = const LatLng(55.751244, 37.618423);
  
  double _totalDistance = 0.0;
  int _realSeconds = 0;
  int _gameSeconds = 0;
  bool _isWalking = true;
  bool _isEnding = false;
  bool _hasLocation = false;
  bool _isMapReady = false;
  String _locationStatus = "Запрос разрешения...";
  
  late Timer _timer;
  
  @override
  void initState() {
    super.initState();
    print('WalkScreen инициализирован с walkId: ${widget.walkId}');
    _initLocationTracking();
  }
  
  Future<void> _initLocationTracking() async {
    bool hasPermission = await _locationService.requestPermissions();
    
    if (!hasPermission) {
      setState(() {
        _locationStatus = "Нет разрешения на геолокацию";
      });
      _showLocationErrorDialog();
      return;
    }
    
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() {
        _locationStatus = "GPS выключен";
      });
      _showLocationErrorDialog();
      return;
    }
    
    setState(() {
      _locationStatus = "Отслеживание позиции...";
    });
    
    Position? startPosition = await _locationService.getCurrentPosition();
    if (startPosition != null) {
      setState(() {
        _currentPosition = LatLng(startPosition.latitude, startPosition.longitude);
        _hasLocation = true;
        _locationStatus = "Отслеживание активно";
      });
      _moveCameraToCurrentPosition();
    }
    
    _locationService.onDistanceUpdated = (distance) {
      if (mounted && _isWalking) {
        setState(() {
          _totalDistance = distance;
        });
      }
    };
    
    _locationService.onPositionUpdated = (position) {
      if (mounted && _isWalking) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _moveCameraToCurrentPosition();
      }
    };
    
    _locationService.startTracking();
    _startTimer();
  }
  
  void _moveCameraToCurrentPosition() {
    if (_hasLocation && _isMapReady) {
      _mapController.move(_currentPosition, 17.0);
    }
  }
  
  void _showLocationErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка геолокации'),
        content: const Text('Для отслеживания прогулки необходим доступ к геолокации. Пожалуйста, включите GPS и дайте разрешение.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Выйти'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _initLocationTracking();
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isWalking || !mounted) return;
      
      setState(() {
        _realSeconds++;
        _gameSeconds += _timeMultiplier.toInt();
      });
    });
  }

  Future<void> _endWalk() async {
    if (_isEnding) return;
    if (!_isWalking) return;
    
    setState(() {
      _isEnding = true;
      _isWalking = false;
    });
    
    _locationService.stopTracking();
    _timer.cancel();
    
    final distanceInMeters = _totalDistance.round();
    final durationInSeconds = _gameSeconds;
    
    print('=== ЗАВЕРШЕНИЕ ПРОГУЛКИ ===');
    print('Расстояние: ${distanceInMeters}м');
    print('Время: ${durationInSeconds}с');
    
    // Показываем диалог загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );
    
    try {
      final result = await _walkService.endWalk(
        widget.walkId,
        distanceInMeters.toDouble(),
        durationInSeconds,
      );
      
      if (!mounted) return;
      
      // Закрываем диалог загрузки
      Navigator.pop(context);
      
      if (result != null) {
        // Показываем диалог с наградами
        final dialogResult = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => WalkResultDialog(
            result: result,
            onCollect: () {
              Navigator.pop(dialogContext, true);
            },
          ),
        );
        
        if (dialogResult == true && mounted) {
          // Закрываем экран прогулки
          Navigator.pop(context);
          // Обновляем главный экран
          widget.onWalkEnd(result);
        }
      } else {
        // Ошибка - просто закрываем экран
        Navigator.pop(context);
      }
    } catch (e) {
      print('Ошибка: $e');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при завершении прогулки')),
        );
        Navigator.pop(context);
      }
    }
  }

  String _formatGameTime() {
    final hours = _gameSeconds ~/ 3600;
    final minutes = (_gameSeconds % 3600) ~/ 60;
    final seconds = _gameSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} км';
    }
    return '${meters.toStringAsFixed(0)} м';
  }

  @override
  void dispose() {
    _locationService.stopTracking();
    if (_timer.isActive) {
      _timer.cancel();
    }
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 17.0,
              onMapReady: () {
                _isMapReady = true;
                if (_hasLocation) {
                  _moveCameraToCurrentPosition();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.walkie',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 50,
                    height: 50,
                    point: _currentPosition,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppTheme.secondaryColor.withOpacity(0.95),
                border: Border.all(color: AppTheme.primaryColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Прогулка',
                    style: TextStyle(
                      fontFamily: 'Sigmar Cyrillic',
                      fontSize: 24,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(_formatGameTime(), 'Время'),
                      _buildStatColumn(_formatDistance(_totalDistance), 'Дистанция'),
                    ],
                  ),
                  if (_timeMultiplier > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'x${_timeMultiplier.toStringAsFixed(0)} ускорение',
                        style: const TextStyle(
                          fontFamily: 'Pangolin',
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          if (_hasLocation)
            Positioned(
              bottom: 100,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () {
                  _moveCameraToCurrentPosition();
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: Colors.blue),
              ),
            ),
          
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _isEnding ? null : _endWalk,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
              ),
              child: _isEnding
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Завершить прогулку',
                      style: TextStyle(
                        fontFamily: 'Sigmar Cyrillic',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          
          if (!_hasLocation)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _locationStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Pangolin',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Sigmar Cyrillic',
            fontSize: 20,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pangolin',
            fontSize: 14,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}