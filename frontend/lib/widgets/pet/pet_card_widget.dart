import 'package:flutter/material.dart';

class PetCardWidget extends StatelessWidget {
  final int petIndex;
  final Color backgroundColor;
  final bool isSelected;


  const PetCardWidget({
    super.key,
    required this.backgroundColor,
    this.isSelected = false,
    required this.petIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Определяем цвет в зависимости от выбора
    final cardColor = isSelected 
        ? const Color.fromRGBO(172, 205, 152, 1)  // ACCD98 — выбрана
        : const Color.fromRGBO(228, 198, 140, 1); // E4C78C — не выбрана

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromRGBO(245, 225, 184, 1),
        border: Border.all(
          color: const Color.fromRGBO(130, 115, 84, 1),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Container(
        width: 191,
        height: 237,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: cardColor,  // ← Меняется только цвет фона
          border: Border.all(
            color: const Color.fromRGBO(130, 115, 84, 1),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              child: Image.asset(
                'assets/images/pet_$petIndex.png',
                fit: BoxFit.fitWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}