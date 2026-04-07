import 'package:flutter/material.dart';

class PetCardWidget extends StatelessWidget {
  final Color backgroundColor;

  const PetCardWidget({
    super.key,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromRGBO(245, 225, 184, 1),
        border: Border.all(color: const Color.fromRGBO(130, 115, 84, 1), width: 2),
      ),
      padding: const EdgeInsets.all(10),
      child: Container(
        width: 191,
        height: 237,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: backgroundColor,
          border: Border.all(color: const Color.fromRGBO(130, 115, 84, 1), width: 2),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -38,
              left: -28,
              child: Image.asset(
                'assets/images/1.png',
                width: 247,
                height: 329,
                fit: BoxFit.fitWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}