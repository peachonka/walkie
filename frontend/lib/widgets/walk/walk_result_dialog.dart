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
    final itemsCount = result['items_collected'] ?? 0;
    
    // Преобразуем секунды в минуты (1 секунда = 1 минута игрового времени)
    final totalMinutes = durationSeconds;
    
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    final durationStr = hours > 0 
        ? '${hours}ч ${minutes}м'
        : '${minutes}м';
    
    // Если хотите показывать и секунды (но по логике 1 сек = 1 мин, секунд быть не должно)
    // final durationStr = hours > 0 
    //     ? '${hours}ч ${minutes}м'
    //     : minutes > 0
    //         ? '${minutes}м'
    //         : '${durationSeconds}с';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Container(
          width: 380,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Прогулка завершена!',
                  style: TextStyle(
                    fontFamily: 'Sigmar Cyrillic',
                    fontSize: 22,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildResultRow('Пройдено', '${distance.toStringAsFixed(2)} км'),
                const SizedBox(height: 10),
                _buildResultRow('Время', durationStr),
                const SizedBox(height: 10),
                _buildResultRow('Найдено предметов', itemsCount.toString()),
                
                const SizedBox(height: 20),
                
                if (result['new_achievements'] != null && result['new_achievements'].isNotEmpty)
                  Column(
                    children: [
                      const Divider(color: AppTheme.primaryColor),
                      const SizedBox(height: 12),
                      const Text(
                        'Новые достижения!',
                        style: TextStyle(
                          fontFamily: 'Sigmar Cyrillic',
                          fontSize: 14,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...result['new_achievements'].map((ach) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '🏆 $ach',
                          style: const TextStyle(
                            fontFamily: 'Pangolin',
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
                      const SizedBox(height: 16),
                    ],
                ),
                
                Center(
                  child: CustomButton(
                    text: 'Собрать награды',
                    onPressed: () {
                      Navigator.of(context).pop();
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (context.mounted) {
                          onCollect();
                        }
                      });
                    },
                    width: 200,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pangolin',
            fontSize: 14,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Sigmar Cyrillic',
            fontSize: 16,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}