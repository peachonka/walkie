import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pet_service.dart';
import 'home_screen.dart';
import 'pet_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PetService _petService = PetService();

  @override
  void initState() {
    super.initState();
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    _checkPetAndNavigate();
  }

  Future<void> _checkPetAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final hasPet = await _petService.hasPet();
    
    if (!mounted) return;
    
    if (hasPet) {
      await _loadAndSavePetInfo();
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PetSelectionScreen()),
      );
    }
  }

  Future<void> _loadAndSavePetInfo() async {
    try {
      final petInfo = await _petService.getPet();
      if (petInfo != null && petInfo['name'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pet_name', petInfo['name']);
        print('-- Имя питомца загружено из API: ${petInfo['name']}');
      } else {
        print('-- Не удалось загрузить имя питомца из API');
      }
    } catch (e) {
      print('-- Ошибка при загрузке информации о питомце: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}