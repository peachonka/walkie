import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class StatsWidget extends StatelessWidget {
  const StatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Статистика',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontFamily: 'Sigmar Cyrillic',
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatColumn('23', 'прогулки'),
                const SizedBox(width: 32),
                _buildStatColumn('400', 'часов'),
                const SizedBox(width: 32),
                _buildStatColumn('500', 'км пройдено'),
              ],
            ),
          ],
        ),
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