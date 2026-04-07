import 'package:flutter/material.dart';
import 'dart:math' as math;

class CollectionItemWidget extends StatelessWidget {
  final String? text;
  final String? imagePath;
  final double rotateAngle;

  const CollectionItemWidget({
    super.key,
    this.text,
    this.imagePath,
    this.rotateAngle = 0,
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
        width: 110,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromRGBO(228, 198, 140, 1),
          border: Border.all(color: const Color.fromRGBO(130, 115, 84, 1), width: 2),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (text != null) {
      return Center(
        child: Transform.rotate(
          angle: 35.975 * (math.pi / 180),
          child: Text(
            text!,
            style: const TextStyle(
              fontFamily: 'Sigmar Cyrillic',
              fontSize: 20,
            ),
          ),
        ),
      );
    }
    if (imagePath != null) {
      return Center(
        child: Transform.rotate(
          angle: rotateAngle * (math.pi / 180),
          child: Image.asset(
            imagePath!,
            fit: BoxFit.fitWidth,
          ),
        ),
      );
    }
    return Container();
  }
}