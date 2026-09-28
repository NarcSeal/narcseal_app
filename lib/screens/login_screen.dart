import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../services/api_service.dart';
import '../navigation/app_router.dart';

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
  bool _isLoading = false;

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final success = await ApiService.login(username, password);
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required bool isPassword,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        style: NarcSealTypography.body,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: NarcSealColors.titaniumGray),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: NarcSealColors.titaniumGray,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NarcSealColors.warmOffWhite,
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle background
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(
                  'assets/images/backgrounds/wave_pattern.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ),
            
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/branding/narcseal_logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.security,
                        size: 120,
                        color: NarcSealColors.titaniumGray,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Brand Name
                  Text(
                    'NarcSeal',
                    style: NarcSealTypography.appTitle.copyWith(
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Tagline
                  Text(
                    'Capture · Verify · Preserve',
                    style: NarcSealTypography.body.copyWith(
                      color: NarcSealColors.graphite,
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 48),

                  // Inputs
                  _buildTextField(
                    hint: 'Badge Number',
                    icon: Icons.badge_outlined,
                    isPassword: false,
                    controller: _badgeController,
                  ),
                  _buildTextField(
                    hint: 'Username',
                    icon: Icons.person_outline,
                    isPassword: false,
                    controller: _usernameController,
                  ),
                  _buildTextField(
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                  ),

                  const SizedBox(height: 8),

                  // Authenticate Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading 
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: NarcSealColors.white, strokeWidth: 2)
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('AUTHENTICATE', style: NarcSealTypography.buttonText),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  ),

                  const SizedBox(height: 24),
                  
                  // OR divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: NarcSealTypography.label.copyWith(
                            color: NarcSealColors.graphite,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  // SSO Button
                  OutlinedButton(
                    onPressed: () {
                      // SSO Logic placeholder
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_balance, size: 20), // Placeholder for Indian Emblem
                        const SizedBox(width: 12),
                        Text(
                          'Login with Government SSO',
                          style: NarcSealTypography.buttonText.copyWith(
                            color: NarcSealColors.titaniumGray,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: NarcSealTypography.label.copyWith(
                          color: NarcSealColors.graphite,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom Text
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'TRUST',
                    style: NarcSealTypography.navLabel.copyWith(
                      color: NarcSealColors.graphite,
                      letterSpacing: 2,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('|', style: TextStyle(color: NarcSealColors.paleOlive)),
                  ),
                  Text(
                    'EVIDENCE',
                    style: NarcSealTypography.navLabel.copyWith(
                      color: NarcSealColors.graphite,
                      letterSpacing: 2,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('|', style: TextStyle(color: NarcSealColors.paleOlive)),
                  ),
                  Text(
                    'JUSTICE',
                    style: NarcSealTypography.navLabel.copyWith(
                      color: NarcSealColors.graphite,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
