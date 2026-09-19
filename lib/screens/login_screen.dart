import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _badgeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleLogin() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  Widget _buildTextField({
    required String hint,
    required bool isPassword,
    required double topPercent,
    required double heightPercent,
    required TextEditingController controller,
  }) {
    return Positioned(
      top: topPercent,
      height: heightPercent,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0), // Limits to the width of the metallic box
        child: Align(
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            obscureText: isPassword && _obscurePassword,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 15,
              ),
              // Pushes text past the vertical icon divider
              contentPadding: const EdgeInsets.only(left: 65.0, top: 12.0, bottom: 12.0),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
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
                    top: h * 0.08,
                    right: w * 0.05,
                    child: IconButton(
                      icon: const Icon(Icons.fingerprint, color: Colors.white, size: 32),
                      onPressed: () {
                        Navigator.pushNamed(context, '/biometric', arguments: {'mode': 'login'});
                      },
                    ),
                  ),

                  // Badge Number
                  _buildTextField(
                    hint: 'Badge Number',
                    isPassword: false,
                    topPercent: h * 0.505,
                    heightPercent: h * 0.08,
                    controller: _badgeController,
                  ),

                  // Username
                  _buildTextField(
                    hint: 'Username',
                    isPassword: false,
                    topPercent: h * 0.592,
                    heightPercent: h * 0.08,
                    controller: _usernameController,
                  ),

                  // Password
                  _buildTextField(
                    hint: 'Password',
                    isPassword: true,
                    topPercent: h * 0.678,
                    heightPercent: h * 0.08,
                    controller: _passwordController,
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
