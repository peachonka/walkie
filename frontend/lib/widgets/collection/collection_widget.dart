import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'collection_item_widget.dart';

class CollectionWidget extends StatelessWidget {
  final VoidCallback onClose;

  const CollectionWidget({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppTheme.secondaryColor,
        border: Border.all(color: AppTheme.primaryColor, width: 2),
      ),
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppTheme.backgroundColor,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildCollectionGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Коллекция',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontFamily: 'Sigmar Cyrillic',
            fontSize: 20,
          ),
        ),
        Row(
          children: [
            CollectionIconButton(),
            SizedBox(width: 20),
            CollectionIconButton2(),
          ],
        ),
      ],
    );
  }

  Widget _buildCollectionGrid() {
    return Column(
      children: [
        Row(
          children: [
            CollectionItemWidget(text: 'Шкаф'),
            const SizedBox(width: 20),
            CollectionItemWidget(imagePath: 'assets/images/Image7.png'),
            const SizedBox(width: 20),
            CollectionItemWidget(
              imagePath: 'assets/images/Image18.png',
              rotateAngle: 38.77,
            ),
            const SizedBox(width: 20),
            CollectionItemWidget(imagePath: 'assets/images/Image13.png'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            CollectionItemWidget(),
            const SizedBox(width: 20),
            CollectionItemWidget(),
            const SizedBox(width: 20),
            CollectionItemWidget(),
            const SizedBox(width: 20),
            CollectionItemWidget(),
          ],
        ),
      ],
    );
  }
}

// Добавьте в конец файла:

class CollectionIconButton extends StatelessWidget {
  const CollectionIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            top: 12,
            left: 36,
            child: Container(
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class CollectionIconButton2 extends StatelessWidget {
  const CollectionIconButton2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            top: 12,
            left: 36,
            child: Container(
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}