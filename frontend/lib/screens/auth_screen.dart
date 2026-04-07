import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Цвета из дизайна
const Color primaryColor = Color(0xFF135B78);
const Color accentColor = Color(0xFF2C6E8A);
const Color logoColor = Color(0xFF3D0066);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  void _navigateToHome() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Успешный вход! (демо-режим)'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      
      final email = _emailController.text.trim();
      final userName = email.split('@')[0];
      
      if (_isSignUp) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ Регистрация успешна! Добро пожаловать, $userName!'),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() => _isSignUp = false);
        _passwordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ Добро пожаловать, $userName!'),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        _navigateToHome();
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _obscurePassword = true;
    });
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Получаем ширину экрана
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Адаптивная ширина для полей ввода
    final double inputWidth = screenWidth - 76 > 316 ? 316 : screenWidth - 76;
    final double finalInputWidth = inputWidth < 260 ? 260 : inputWidth;
    
    // Кнопка теперь такой же ширины, как поля ввода
    final double buttonWidth = _isSignUp ? finalInputWidth : (screenWidth - 215 > 178 ? 178 : screenWidth - 215);
    final double finalButtonWidth = _isSignUp ? buttonWidth : (buttonWidth < 120 ? 120 : buttonWidth);
    
    return Scaffold(
      appBar: null,
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Отступ сверху
                  const SizedBox(height: 150),
                  
                  // Логотип WALKIE
                  const Text(
                    'Walkie',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Sigmar Cyrillic',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 64,
                      height: 1.0,
                      letterSpacing: 0,
                      color: logoColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Заголовок (Авторизация/Регистрация)
                  Text(
                    _isSignUp ? 'Регистрация' : 'Авторизация',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Sigmar Cyrillic',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 32,
                      height: 1.0,
                      letterSpacing: 0,
                      color: Color.fromRGBO(61, 0, 102, 1),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Форма
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Поле Email
                        Container(
                          width: finalInputWidth,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1D5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF827454),
                              width: 1,
                            ),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(61, 0, 102, 1),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: const TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(120, 117, 126, 0.5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Введите email';
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Введите корректный email';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 27),
                        
                        // Поле Пароль
                        Container(
                          width: finalInputWidth,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1D5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF827454),
                              width: 1,
                            ),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(61, 0, 102, 1),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Пароль',
                              hintStyle: const TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(120, 117, 126, 0.5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color.fromRGBO(120, 117, 126, 0.5),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Введите пароль';
                              }
                              if (value.length < 6) {
                                return 'Пароль должен быть не менее 6 символов';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 42),
                        
                        // Кнопка (Войти или Зарегистрироваться)
                        SizedBox(
                          width: finalButtonWidth,
                          height: 42,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFF1D5),
                              foregroundColor: const Color(0xFF827454),
                              disabledBackgroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: Color(0xFF827454),
                                  width: 2,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF827454),
                                    ),
                                  )
                                : Text(
                                    _isSignUp ? 'Зарегистрироваться' : 'Войти',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Sigmar Cyrillic',
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 20,
                                      height: 1.0,
                                      letterSpacing: 0,
                                      color: Color(0xFF827454),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Кнопка "или зарегистрироваться" / "или войти"
                        GestureDetector(
                          onTap: _isLoading ? null : _toggleMode,
                          child: Text(
                            _isSignUp
                                ? 'или войти, если уже есть аккаунт'
                                : 'или зарегистрироваться',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.2,
                              letterSpacing: 0,
                              color: Color.fromRGBO(61, 0, 102, 1),
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.solid,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}