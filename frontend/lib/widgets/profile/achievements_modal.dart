import 'package:flutter/material.dart';
import '../../services/achievements_service.dart';
import '../../theme/app_theme.dart';

class AchievementsModal extends StatefulWidget {
  const AchievementsModal({super.key});

  @override
  State<AchievementsModal> createState() => _AchievementsModalState();
}

class _AchievementsModalState extends State<AchievementsModal> {
  final AchievementsService _achievementsService = AchievementsService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _achievements = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final achievements = await _achievementsService.getAchievementProgress();
      setState(() {
        _achievements = achievements;
        _isLoading = false;
      });
      print('Загружены достижения: ${_achievements.length}');
    } catch (e) {
      print('Ошибка загрузки достижений: $e');
      setState(() {
        _error = 'Не удалось загрузить достижения';
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
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Text(
                'Достижения',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontFamily: 'Sigmar Cyrillic',
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              onPressed: _loadAchievements,
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

    if (_achievements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Пока нет достижений',
              style: TextStyle(
                fontFamily: 'Pangolin',
                fontSize: 18,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Проходите больше прогулок,\nчтобы открывать достижения!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pangolin',
                fontSize: 14,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        final isEarned = achievement['is_earned'] ?? false;
        final progress = (achievement['progress_percent'] ?? 0).toInt();
        final target = achievement['target'] ?? 0;
        final currentValue = achievement['current_value'] ?? 0;
        final name = achievement['name'] ?? 'Достижение';
        final description = achievement['description'] ?? '';
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isEarned 
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.white,
              border: Border.all(
                color: isEarned 
                  ? AppTheme.primaryColor 
                  : AppTheme.primaryColor.withOpacity(0.3),
                width: isEarned ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isEarned 
                      ? AppTheme.primaryColor 
                      : AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getAchievementIcon(achievement['icon']),
                    size: 36,
                    color: isEarned ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontFamily: 'Sigmar Cyrillic',
                                fontSize: 16,
                                color: AppTheme.primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isEarned)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Получено',
                                    style: TextStyle(
                                      fontFamily: 'Pangolin',
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontFamily: 'Pangolin',
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!isEarned)
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$currentValue / $target',
                                  style: const TextStyle(
                                    fontFamily: 'Pangolin',
                                    fontSize: 10,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                Text(
                                  '$progress%',
                                  style: const TextStyle(
                                    fontFamily: 'Pangolin',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress / 100,
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                                color: AppTheme.primaryColor,
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getAchievementIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'walk':
      case 'steps':
        return Icons.directions_walk;
      case 'distance':
        return Icons.straighten;
      case 'time':
        return Icons.access_time;
      case 'walks':
        return Icons.pets;
      case 'streak':
        return Icons.local_fire_department;
      case 'perfect':
        return Icons.emoji_events;
      default:
        return Icons.emoji_events;
    }
  }
}