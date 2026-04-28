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
    final steps = result['steps'] ?? 0; // Добавляем шаги
    
    // items_collected - это список предметов
    final itemsList = result['items_collected'];
    // Получаем общее количество предметов (суммируем quantity)
    int itemsCount = 0;
    if (itemsList is List) {
        for (var item in itemsList) {
          final quantity = item['quantity'];
        if (quantity != null) {
        itemsCount += (quantity is int ? quantity : (quantity as num).toInt());
        }
      }
    }
    
    // new_achievements - это список достижений
    final newAchievements = result['new_achievements'];
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
                      Container(width: 1, height: 30, color: AppTheme.primaryColor),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              steps.toString(),
                              style: const TextStyle(
                                fontFamily: 'Sigmar Cyrillic',
                                fontSize: 14,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Шаги',
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
                
                // Количество найденных предметов
                if (itemsCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '📦 ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Найдено предметов: $itemsCount',
                          style: const TextStyle(
                            fontFamily: 'Sigmar Cyrillic',
                            fontSize: 13,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Новые достижения - выводим name и description
                if (hasAchievements) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '🏆 Новые достижения!',
                    style: TextStyle(
                      fontFamily: 'Sigmar Cyrillic',
                      fontSize: 13,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(newAchievements as List).map((ach) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.orange.withOpacity(0.15),
                      border: Border.all(color: Colors.orange, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ach['name']?.toString() ?? 'Достижение',
                          style: const TextStyle(
                            fontFamily: 'Sigmar Cyrillic',
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (ach['description'] != null && ach['description'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              ach['description'].toString(),
                              style: const TextStyle(
                                fontFamily: 'Pangolin',
                                fontSize: 10,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )).toList(),
                  const SizedBox(height: 8),
                ],
                
                // Если ничего не найдено
                if (itemsCount == 0 && !hasAchievements)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
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
                
                // Кнопка
                SizedBox(
                  width: 160,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onCollect();
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