import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pet_service.dart';
import 'home_screen.dart';

class PetSelectionScreen extends StatefulWidget {
  const PetSelectionScreen({super.key});

  @override
  State<PetSelectionScreen> createState() => _PetSelectionScreenState();
}

class _PetSelectionScreenState extends State<PetSelectionScreen> {
  final PetService _petService = PetService();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  List<Map<String, dynamic>> _petTypes = [];
  int? _selectedPetId;
  int? _realPetId;

  @override
  void initState() {
    super.initState();
    _loadPetTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadPetTypes() async {
    setState(() => _isLoading = true);
    try {
      final types = await _petService.getPetTypes();
      print('-- Загружено типов питомцев: ${types.length}');
      
      if (types.isNotEmpty) {
        _realPetId = types.first['id'];
        final firstPet = types.first;
        
        _petTypes = List.generate(5, (index) => {
          'id': index + 1,
          'realId': _realPetId,
          'type': firstPet['type'],
          'avatar': firstPet['avatar'],
        });
        print('-- Создано 5 карточек');
        print('-- Реальный ID питомца для отправки: $_realPetId');
      } else {
        _petTypes = [];
      }
    } catch (e) {
      print('-- Ошибка загрузки типов: $e');
      _petTypes = [];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createPet() async {
    final name = _nameController.text.trim();
    
    if (_selectedPetId == null) {
      _showError('Выберите питомца');
      return;
    }

    if (name.isEmpty) {
      _showError('Введите имя питомца');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final selectedPet = _petTypes.firstWhere((pet) => pet['id'] == _selectedPetId);
      final petIdToSend = selectedPet['realId'];
      
      print('-- Выбран питомец: ${selectedPet['type']}');
      print('-- Отправляем запрос с petId: $petIdToSend, name: $name');
      
      final success = await _petService.createPet(petIdToSend, name);
      
      if (success && mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pet_name', name);
        print('-- Имя питомца сохранено в хранилище: $name');
        
        print('-- Питомец успешно создан, переход на HomeScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showError('Не удалось создать питомца');
      }
    } catch (e) {
      print('-- Ошибка при создании: $e');
      _showError('Ошибка: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _petTypes.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isButtonEnabled = _selectedPetId != null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFFFCF5ED),
          border: Border.all(
            color: const Color(0xFF827454),
            width: 2,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Выберите питомца',
                      style: TextStyle(
                        fontFamily: 'Sigmar Cyrillic',
                        fontSize: 28,
                        color: Color(0xFF827454),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 250,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFFFFF1D5),
                          border: Border.all(color: const Color(0xFF827454), width: 1),
                        ),
                        child: TextFormField(
                          controller: _nameController,
                          focusNode: _focusNode,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'Имя питомца',
                            hintStyle: TextStyle(fontSize: 14, color: Color(0xFFB1B1B1)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: _petTypes.map((pet) {
                      final isSelected = _selectedPetId == pet['id'];
                      return _buildPetCard(pet, isSelected);
                    }).toList(),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 24, 24),
        child: ElevatedButton(
          onPressed: isButtonEnabled && !_isLoading ? _createPet : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isButtonEnabled 
                ? const Color(0xFFFFF1D5)
                : const Color(0xFFB1B1B1),
            foregroundColor: isButtonEnabled 
                ? const Color(0xFF827454)
                : const Color(0xFF666666),
            disabledBackgroundColor: const Color(0xFFB1B1B1),
            disabledForegroundColor: const Color(0xFF666666),
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 0),
            minimumSize: const Size(0, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isButtonEnabled 
                    ? const Color(0xFF827454)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF827454),
                  ),
                )
              : const Text(
                  'Выбрать',
                  style: TextStyle(
                    fontFamily: 'Sigmar Cyrillic',
                    fontSize: 22,
                  ),
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet, bool isSelected) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 24),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPetId = pet['id'];
          });
          _focusNode.unfocus();
          print('-- Выбрана карточка: id=${pet['id']}, тип=${pet['type']}');
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFF6E2B9),
                border: Border.all(
                  color: const Color(0xFF827454),
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isSelected 
                      ? const Color(0xFFACCD98)
                      : const Color(0xFFE4C78C),
                  border: Border.all(
                    color: const Color(0xFF827454),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/pet_0.png',
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.pets,
                            size: 60,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pet['type'],
                      style: const TextStyle(
                        fontFamily: 'Sigmar Cyrillic',
                        fontSize: 18,
                        color: Color(0xFF3D0066),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}