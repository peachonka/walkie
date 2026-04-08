import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/game/game_background.dart';
import '../widgets/game/game_pet.dart';
import '../widgets/game/draggable_item.dart';
import '../widgets/game/game_menu_buttons.dart';

// ← Класс _ItemData ЗДЕСЬ, на верхнем уровне
class _ItemData {
  final Offset position;
  final Size size;

  const _ItemData({
    required this.position,
    required this.size,
  });
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // ← А здесь уже используем _ItemData
  final Map<String, _ItemData> _items = {
    'carpet': const _ItemData(
      position: Offset(200, 100),
      size: Size(500, 500),
    ),
    // 'bowl': const _ItemData(
    //   position: Offset(500, 300),
    //   size: Size(200, 200),
    // ),
  };

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            const GameBackground(),
            ..._buildDraggableItems(),
            const GamePet(),
            const Positioned(
              top: 20,
              left: 20,
              child: GameMenuButtons(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDraggableItems() {
    return _items.entries.map((entry) {
      return DraggableItem(
        key: ValueKey(entry.key),
        itemId: entry.key,
        imagePath: 'assets/images/items/${entry.key}.png',
        initialPosition: entry.value.position,
        size: entry.value.size,
        onPositionChanged: (newPosition) {
          setState(() {
            _items[entry.key] = _ItemData(
              position: newPosition,
              size: entry.value.size,
            );
          });
          _sendPositionToBackend(entry.key, newPosition);
        },
      );
    }).toList();
  }

  void _sendPositionToBackend(String itemId, Offset position) {
    debugPrint('Item $itemId moved to: (${position.dx}, ${position.dy})');
  }
}