import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _badgeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/onboarding/login_bg.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  
                  // Biometric Button Top Right
                  Positioned(
                    top: 50,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.fingerprint, color: Colors.white, size: 32),
                      onPressed: () {
                        Navigator.pushNamed(context, '/biometric', arguments: {'mode': 'login'});
                      },
                    ),
                  ),

                  // Badge Number
                  Positioned(
                    top: h * 0.50,
                    left: w * 0.15,
                    right: w * 0.15,
                    child: TextField(
                      controller: _badgeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Badge Number',
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),

                  // Username
                  Positioned(
                    top: h * 0.59,
                    left: w * 0.15,
                    right: w * 0.15,
                    child: TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Username',
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),

                  // Password
                  Positioned(
                    top: h * 0.68,
                    left: w * 0.15,
                    right: w * 0.15,
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),

                  // Authenticate Button
                  Positioned(
                    top: h * 0.795,
                    left: w * 0.1,
                    right: w * 0.1,
                    height: h * 0.08,
                    child: GestureDetector(
                      onTap: _handleLogin,
                      child: Container(
                        color: Colors.transparent, // Invisible interactive zone
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
