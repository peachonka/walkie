import 'package:flutter/material.dart';
import 'walk_controls_widget.dart';

class WalkScreenWidget extends StatelessWidget {
  final VoidCallback onEndWalk;

  const WalkScreenWidget({
    super.key,
    required this.onEndWalk,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 852,
      height: 393,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.6031836271286011, 0.1613570749759674),
          end: Alignment(-0.1613570749759674, -0.1283380538225174),
          colors: const [
            Color.fromRGBO(247, 239, 225, 0.7),
            Color.fromRGBO(252, 245, 237, 1),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -119,
            left: 0,
            child: Image.asset(
              'assets/images/Image14.png',
              width: 852,
              height: 514,
              fit: BoxFit.fitWidth,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 852,
              height: 393,
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          ..._buildActionButtons(),
          Positioned(
            top: 331,
            left: 521,
            child: WalkControlsWidget(onEndWalk: onEndWalk),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    // Buttons at various positions
    return [
      _buildActionButton(top: 84, left: 481),
      _buildActionButton(top: 108, left: 117),
      _buildActionButton(top: 203, left: 327),
      _buildActionButton(top: 360, left: 433),
      _buildActionButton(top: 236, left: 752),
      _buildActionButton(top: 228, left: 31),
    ];
  }

  Widget _buildActionButton({required double top, required double left}) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: const Color.fromRGBO(245, 225, 184, 1),
          border: Border.all(color: const Color.fromRGBO(130, 115, 84, 1), width: 2),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 40,
              child: Container(
                width: 32,
                height: 32,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}