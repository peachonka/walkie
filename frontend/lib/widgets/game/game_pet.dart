import 'package:flutter/material.dart';

class GamePet extends StatelessWidget {
  const GamePet({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(  // ← ВАЖНО: пропускает касания к нижним слоям
        child: Image.asset(
          'assets/images/pet_0.png',
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}