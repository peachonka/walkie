import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/app_theme.dart';

class WalkControlsWidget extends StatelessWidget {
  final VoidCallback onEndWalk;

  const WalkControlsWidget({
    super.key,
    required this.onEndWalk,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEndWalk,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.secondaryColor,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        child: Transform.rotate(
          angle: 1.5308806722812968e-22 * (math.pi / 180),
          child: const Text(
            'Закончить прогулку',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontFamily: 'Sigmar Cyrillic',
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}