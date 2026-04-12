import 'package:flutter/material.dart';

class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Stack(
        children: [
          // Фоновая картинка
          Positioned.fill(
            child: Image.asset(
              'assets/images/Walkiesplash1.png',
              fit: BoxFit.cover,
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(
              right: 280,  // Отступ справа
              bottom: 50,  // Отступ снизу
            ),
            child: Align(
              alignment: Alignment.bottomRight,  // Прижимаем к правому нижнему углу
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,  // Текст выровнен по правому краю

                children: [
                  const Text(
                    'Walkie',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 218, 162, 1),
                      fontFamily: 'Sigmar Cyrillic',
                      fontSize: 128,
                    ),
                  ),
                  const Text(
                    'исследуй и собирай',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 218, 162, 1),
                      fontFamily: 'Pangolin',
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}