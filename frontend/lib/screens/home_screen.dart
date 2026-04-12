import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Тут будет заставка'),
            const SizedBox(height: 20),
            Text('Добро пожаловать, ${user?.email ?? 'пользователь'}!'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Выйти'),
            ),
          ],
        ),
      ),
    );
  }
}