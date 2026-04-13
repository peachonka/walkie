import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/custom_button.dart';

class WalkResultDialog extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onCollect;

  const WalkResultDialog({
    super.key,
    required this.result,
    required this.onCollect,
  });

  @override
  Widget build(BuildContext context) {
    final distance = (result['distance'] ?? 0) / 1000;
    final durationSeconds = result['duration'] ?? 0;
    
    final itemsCollected = result['items_collected'];
    final newAchievements = result['new_achievements'];
    
    final hasItems = itemsCollected is List && itemsCollected.isNotEmpty;
    final hasAchievements = newAchievements is List && newAchievements.isNotEmpty;
    
    final totalMinutes = durationSeconds ~/ 60;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    final durationStr = hours > 0 
        ? '${hours}ч ${minutes}м'
        : '${minutes}м';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: 320,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ПРОГУЛКА\nЗАВЕРШЕНА!',
                  style: TextStyle(
                    fontFamily: 'Sigmar Cyrillic',
                    fontSize: 20,
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Статистика
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.secondaryColor.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${distance.toStringAsFixed(2)} км',
                              style: const TextStyle(
                                fontFamily: 'Sigmar Cyrillic',
                                fontSize: 14,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Пройдено',
                              style: TextStyle(
                                fontFamily: 'Pangolin',
                                fontSize: 11,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 30, color: AppTheme.primaryColor),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              durationStr,
                              style: const TextStyle(
                                fontFamily: 'Sigmar Cyrillic',
                                fontSize: 14,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Время',
                              style: TextStyle(
                                fontFamily: 'Pangolin',
                                fontSize: 11,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Найденные предметы
                if (hasItems) ...[
                  const Text(
                    '📦 Найдено:',
                    style: TextStyle(
                      fontFamily: 'Sigmar Cyrillic',
                      fontSize: 13,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: (itemsCollected as List).map<Widget>((item) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.green.withOpacity(0.2),
                        border: Border.all(color: Colors.green, width: 1),
                      ),
                      child: Text(
                        item['name']?.toString() ?? 'Предмет',
                        style: const TextStyle(
                          fontFamily: 'Pangolin',
                          fontSize: 10,
                          color: Colors.green,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Новые достижения
                if (hasAchievements) ...[
                  const Text(
                    '🏆 Новые достижения!',
                    style: TextStyle(
                      fontFamily: 'Sigmar Cyrillic',
                      fontSize: 13,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...(newAchievements as List).map((ach) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.orange.withOpacity(0.2),
                      border: Border.all(color: Colors.orange, width: 1),
                    ),
                    child: Text(
                      ach.toString(),
                      style: const TextStyle(
                        fontFamily: 'Pangolin',
                        fontSize: 10,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )),
                  const SizedBox(height: 12),
                ],
                
                // Если ничего не найдено
                if (!hasItems && !hasAchievements)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      '😊 В этот раз ничего не найдено\nПродолжай гулять!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pangolin',
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 12),
                
                // Кнопка - ОБНОВЛЕНО: закрывает диалог и вызывает колбэк
                SizedBox(
                  width: 160,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Закрываем диалог
                      onCollect(); // Вызываем колбэк
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Собрать награды',
                      style: TextStyle(
                        fontFamily: 'Sigmar Cyrillic',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}