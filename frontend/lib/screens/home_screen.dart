import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screen.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _petName = 'Загрузка...';
  
  @override
  void initState() {
    super.initState();
    _setLandscapeOrientation();
    _loadPetName();
  }

  void _setLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    print('HomeScreen: установлена горизонтальная ориентация');
  }

  Future<void> _loadPetName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petName = prefs.getString('pet_name');
      if (petName != null && petName.isNotEmpty) {
        setState(() {
          _petName = petName;
        });
      } else {
        setState(() {
          _petName = 'Питомец';
        });
      }
    } catch (e) {
      print('Ошибка загрузки имени питомца: $e');
      setState(() {
        _petName = 'Питомец';
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Выход из аккаунта',
          style: TextStyle(
            fontFamily: 'Sigmar Cyrillic',
            fontSize: 20,
          ),
        ),
        content: const Text(
          'Вы уверены, что хотите выйти?',
          style: TextStyle(
            fontFamily: 'Pangolin',
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Отмена',
              style: TextStyle(
                fontFamily: 'Pangolin',
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Выйти',
              style: TextStyle(
                fontFamily: 'Pangolin',
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
      );

      try {
        await Supabase.instance.client.auth.signOut();
        print('Выход из Supabase выполнен успешно');
      } catch (e) {
        print('Ошибка при выходе из Supabase: $e');
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('user_id');
        await prefs.remove('pet_name');
        print('Токен удалён из локального хранилища');
      } catch (e) {
        print('Ошибка при очистке хранилища: $e');
      }

      if (context.mounted) {
        Navigator.pop(context);
        
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });
    
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/game_background.png',
              fit: BoxFit.cover,
            ),
          ),
          
          Center(
            child: Image.asset(
              'assets/images/pet_0.png',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
          
          Positioned(
            top: 20,
            left: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuButton(
                  iconPath: 'assets/icons/chart-spline.svg',
                  onPressed: () {
                    print('Статистика');
                    _showComingSoon(context, 'Статистика');
                  },
                ),
                const SizedBox(height: 12),
                
                _buildMenuButton(
                  iconPath: 'assets/icons/shelving-unit.svg',
                  onPressed: () {
                    print('Коллекция');
                    _showComingSoon(context, 'Коллекция');
                  },
                ),
                const SizedBox(height: 12),
                
                _buildMenuButton(
                  iconPath: 'assets/icons/map.svg',
                  onPressed: () {
                    print('Карта');
                    _showComingSoon(context, 'Карта');
                  },
                ),
                const SizedBox(height: 12),
                
                _buildLogoutButton(context),
              ],
            ),
          ),
          
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryColor, width: 1),
              ),
              child: Text(
                _petName,
                style: const TextStyle(
                  fontFamily: 'Pangolin',
                  fontSize: 18,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required String iconPath,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.secondaryColor,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(
              AppTheme.primaryColor,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _logout(context),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.secondaryColor,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        child: const Center(
          child: Icon(
            Icons.logout,
            size: 32,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature в разработке',
          style: const TextStyle(
            fontFamily: 'Pangolin',
            fontSize: 14,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}