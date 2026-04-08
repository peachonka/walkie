import 'package:flutter/material.dart';

class GameBackground extends StatelessWidget {
  const GameBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(  // ← Пропускает касания
        child: Image.asset(
          'assets/images/game_background.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}