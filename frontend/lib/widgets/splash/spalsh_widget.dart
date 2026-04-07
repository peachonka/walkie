import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 393,
      height: 852,
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 400,
            child: Transform.rotate(
              angle: -90 * (math.pi / 180),
              child: Image.asset(
                'assets/images/Walkiesplash1.png',
                width: 900,
                height: 400,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Positioned(
            top: 112,
            left: 240,
            child: Transform.rotate(
              angle: -90 * (math.pi / 180),
              child: const Text(
                'Walkie',
                style: TextStyle(
                  color: Color.fromRGBO(255, 218, 162, 1),
                  fontFamily: 'Sigmar Cyrillic',
                  fontSize: 128,
                ),
              ),
            ),
          ),
          Positioned(
            top: 390,
            left: 68,
            child: Transform.rotate(
              angle: -90 * (math.pi / 180),
              child: const Text(
                'исследуй и собирай',
                style: TextStyle(
                  color: Color.fromRGBO(255, 218, 162, 1),
                  fontFamily: 'Pangolin',
                  fontSize: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}