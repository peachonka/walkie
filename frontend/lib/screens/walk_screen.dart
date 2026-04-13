import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../services/walk_service.dart';
import '../services/walk_simulation_service.dart';

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
  final WalkSimulationService _simulation = WalkSimulationService();
  
  double _totalDistance = 0.0;
  int _realSeconds = 0;      // Реальные секунды для отправки на бэкенд
  int _gameMinutes = 0;       // Игровые минуты для отображения (1 сек = 1 мин)
  bool _isWalking = true;
  bool _isEnding = false;
  
  double _currentLat = 55.751244;
  double _currentLng = 37.618423;
  
  late Timer _timer;
  
  @override
  void initState() {
    super.initState();
    print('WalkScreen инициализирован с walkId: ${widget.walkId}');
    _simulation.startSimulation();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isWalking || !mounted) return;
      
      setState(() {
        // Реальное время для бэкенда (в секундах)
        _realSeconds++;
        
        // Игровое время для отображения (1 реальная секунда = 1 игровая минута)
        _gameMinutes = _realSeconds;
        
        // Обновляем позицию и расстояние
        final newPosition = _simulation.updatePosition();
        _currentLat = newPosition['lat']!;
        _currentLng = newPosition['lng']!;
        _totalDistance = _simulation.getCurrentDistance();
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
    
    _timer.cancel();
    
    // Отправляем на бэкенд РЕАЛЬНЫЕ секунды (не игровые)
    final distanceInMeters = _totalDistance.round();
    final durationInSeconds = _realSeconds;
    
    print('=== ЗАВЕРШЕНИЕ ПРОГУЛКИ ===');
    print('ID прогулки: ${widget.walkId}');
    print('Реальное расстояние: ${distanceInMeters}м (${(distanceInMeters / 1000).toStringAsFixed(2)} км)');
    print('Реальное время: ${durationInSeconds}с');
    print('Игровое время: ${_gameMinutes} минут');
    print('===========================');
    
    // Показываем индикатор загрузки
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
      
      if (mounted) {
        Navigator.pop(context);
      }
      
      if (result != null && mounted) {
        widget.onWalkEnd(result);
      } else {
        if (mounted) {
          // Ошибка - просто закрываем экран без сообщения
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Ошибка при завершении прогулки: $e');
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }

  String _formatGameTime() {
    final hours = _gameMinutes ~/ 60;
    final minutes = _gameMinutes % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00';
    }
    return '${minutes.toString().padLeft(2, '0')}:00';
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} км';
    }
    return '${meters.toStringAsFixed(0)} м';
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/game_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Прогулка',
                  style: TextStyle(
                    fontFamily: 'Sigmar Cyrillic',
                    fontSize: 28,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppTheme.secondaryColor.withOpacity(0.9),
                          border: Border.all(color: AppTheme.primaryColor, width: 2),
                        ),
                        child: Column(
                          children: [
                            _buildStatRow('Время (игровое)', _formatGameTime()),
                            const SizedBox(height: 10),
                            _buildStatRow('Расстояние', _formatDistance(_totalDistance)),
                            const SizedBox(height: 10),
                            _buildStatRow('Широта', _currentLat.toStringAsFixed(6)),
                            const SizedBox(height: 10),
                            _buildStatRow('Долгота', _currentLng.toStringAsFixed(6)),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _isEnding ? null : _endWalk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pangolin',
            fontSize: 16,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Sigmar Cyrillic',
            fontSize: 18,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}