import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/custom_button.dart';

class StartWalkDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const StartWalkDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 400,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Начать прогулку?',
                style: TextStyle(
                  fontFamily: 'Sigmar Cyrillic',
                  fontSize: 28,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Собери новые предметы и порадуй своего питомца!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pangolin',
                  fontSize: 16,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    text: 'Нет',
                    onPressed: onCancel,
                    width: 120,
                  ),
                  CustomButton(
                    text: 'Да, идем!',
                    onPressed: onConfirm,
                    width: 160,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}