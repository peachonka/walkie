import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';

class GameMenuButtons extends StatelessWidget {
  const GameMenuButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMenuButton(
          iconPath: 'assets/icons/chart-spline.svg',
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        _buildMenuButton(
          iconPath: 'assets/icons/shelving-unit.svg',
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        _buildMenuButton(
          iconPath: 'assets/icons/map.svg',
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required String iconPath, // Теперь путь к файлу
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.secondaryColor,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(
              AppTheme.primaryColor,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}