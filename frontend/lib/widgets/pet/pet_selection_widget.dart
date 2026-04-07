import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'pet_card_widget.dart';
import '../common/custom_button.dart';

class PetSelectionWidget extends StatelessWidget {
  final VoidCallback onSelectPet;
  final VoidCallback onCancel;

  const PetSelectionWidget({
    super.key,
    required this.onSelectPet,
    required this.onCancel,
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
            top: 71,
            left: 781,
            child: _buildIconButton(),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: _buildPetSelectionContent(onSelectPet),
          ),
          Positioned(
            top: 320,
            left: 635,
            child: CustomButton(
              text: 'Выбрать',
              onPressed: onSelectPet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: AppTheme.secondaryColor,
        border: Border.all(color: AppTheme.primaryColor, width: 2),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 39,
            child: Container(
              width: 32,
              height: 32,
              color: Colors.white,
              // SVG icon here
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetSelectionContent(VoidCallback onSelectPet) {
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Выберите питомца',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontFamily: 'Sigmar Cyrillic',
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PetCardWidget(
                  backgroundColor: const Color.fromRGBO(171, 204, 151, 1),
                ),
                const SizedBox(width: 32),
                PetCardWidget(
                  backgroundColor: const Color.fromRGBO(228, 198, 140, 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}