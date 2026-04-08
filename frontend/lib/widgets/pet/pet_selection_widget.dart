import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'pet_card_widget.dart';
import '../common/custom_button.dart';

class PetSelectionWidget extends StatefulWidget {
  final void Function(int selectedPetIndex)? onSelectPet;
  final VoidCallback? onCancel;

  const PetSelectionWidget({
    super.key,
    this.onSelectPet,
    this.onCancel,
  });

  @override
  State<PetSelectionWidget> createState() => _PetSelectionWidgetState();
}

class _PetSelectionWidgetState extends State<PetSelectionWidget> {
  int? _selectedPetIndex;  // null = ничего не выбрано

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        children: [
          Container(
            child: _buildPetSelectionContent(),
          ),
          
          // Кнопка "Выбрать"
          Positioned(
            bottom: 30,
            right: 40,
            child: CustomButton(
              text: 'Выбрать',
              isEnabled: _selectedPetIndex != null,
              onPressed: () {
                if (_selectedPetIndex != null) {
                  widget.onSelectPet?.call(_selectedPetIndex!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetSelectionContent() {
  return Container(
    width: double.infinity,
    height: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
              _buildPetCard(
                index: 0,
                color: const Color.fromRGBO(171, 204, 151, 1),
              ),
              const SizedBox(width: 32),
              _buildPetCard(
                index: 1,
                color: const Color.fromRGBO(228, 198, 140, 1),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPetCard({required int index, required Color color}) {
    final isSelected = _selectedPetIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPetIndex = index;
        });
      },
      child: PetCardWidget(
        petIndex: index,
        backgroundColor: color,
        isSelected: isSelected,  // ← Добавьте этот параметр в PetCardWidget
      ),
    );
  }
}