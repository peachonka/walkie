import 'package:flutter/material.dart';
import '../../services/stats_service.dart';
import '../../theme/app_theme.dart';

class StatsModal extends StatefulWidget {
  const StatsModal({super.key});

  @override
  State<StatsModal> createState() => _StatsModalState();
}

class _StatsModalState extends State<StatsModal> {
  final StatsService _statsService = StatsService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final stats = await _statsService.getUserStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
      print('Загружена статистика: $_stats');
    } catch (e) {
      print('Ошибка загрузки статистики: $e');
      setState(() {
        _error = 'Не удалось загрузить статистику';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppTheme.secondaryColor,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.backgroundColor,
            border: Border.all(color: AppTheme.primaryColor, width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Статистика',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontFamily: 'Sigmar Cyrillic',
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 24),
              
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                fontFamily: 'Pangolin',
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStats,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Повторить',
                style: TextStyle(
                  fontFamily: 'Pangolin',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn(
            _stats['total_walks']?.toString() ?? '0',
            'прогулки',
          ),
          _buildStatColumn(
            ((_stats['total_distance_km'] != null 
              ? (double.tryParse(_stats['total_distance_km'].toString()) ?? 0) * 1000 / 0.75 
              : 0).round()).toString(),
            'шагов',
          ),
          _buildStatColumn(
            _stats['total_distance_km']?.toString() ?? '0',
            'км',
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
            color: AppTheme.primaryColor,
            fontFamily: 'Sigmar Cyrillic',
            fontSize: 48,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontFamily: 'Pangolin',
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}