import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;
  final double width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.width = 178,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        width: width,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isEnabled ? AppTheme.secondaryColor : AppTheme.disabledColor,
          border: Border.all(
            color: isEnabled ? AppTheme.primaryColor : Colors.white,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isEnabled ? AppTheme.primaryColor : Colors.white,
              fontFamily: 'Sigmar Cyrillic',
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}