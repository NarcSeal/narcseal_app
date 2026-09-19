import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/colors.dart';
import '../navigation/app_router.dart';
import '../core/widgets/breathing_background.dart';

/// Login Screen — Zero Trust Triple-Layer Authentication Gate
///
/// Security Architecture (from NarcSeal Security Architecture doc):
/// - Layer 1: Device Binding (hardware lock — Android ID + SIM + model)
/// - Layer 2: Credentials (Badge ID + Username + Password) + Biometric
/// - Layer 3: JWT Token (8h access, 7d refresh, flutter_secure_storage)
///
/// Security Features Shown in UI:
/// - No "Sign Up" button — Invitation-Only system
/// - Badge ID field (officer provisioned by District Admin only)
/// - 5-attempt lockout warning (30 min lock), 15-attempt permanent lock
/// - Forced password change on first login
/// - Biometric fingerprint as alternate auth
/// - Device binding status indicator
/// - Screen capture protection (FLAG_SECURE simulated)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _badgeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _badgeFocus = FocusNode();
  final FocusNode _userFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _hasError = false;
  int _failedAttempts = 0;
  bool _isLocked = false;
  bool _isFirstLogin = false; // Would trigger forced password change

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late AnimationController _biometricPulseController;
  late Animation<double> _biometricPulseAnimation;

  late AnimationController _lockIconController;

  @override
  void initState() {
    super.initState();

    // Shake animation for error state
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Biometric button pulse
    _biometricPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _biometricPulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _biometricPulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Lock icon rotation
    _lockIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Add focus listeners for haptic
    for (final node in [_badgeFocus, _userFocus, _passFocus]) {
      node.addListener(() {
        if (node.hasFocus) HapticFeedback.lightImpact();
      });
    }
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _badgeFocus.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    _shakeController.dispose();
    _biometricPulseController.dispose();
    _lockIconController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading || _isLocked) return;

    // Check lockout
    if (_failedAttempts >= 5) {
      setState(() => _isLocked = true);
      _showLockoutWarning();
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    HapticFeedback.mediumImpact();

    // Simulate authentication delay (would be real API call)
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    // Mock validation: accept any non-empty fields
    final badge = _badgeController.text.trim();
    final user = _usernameController.text.trim();
    final pass = _passwordController.text.trim();

    if (badge.isEmpty || user.isEmpty || pass.isEmpty) {
      _triggerError('All fields are required');
      return;
    }

    // Simulate success
    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
    HapticFeedback.heavyImpact();

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  void _triggerError(String message) {
    setState(() {
      _isLoading = false;
      _hasError = true;
      _failedAttempts++;
    });
    HapticFeedback.heavyImpact();
    _shakeController.forward().then((_) => _shakeController.reverse());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: NarcSealColors.resultPositive, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$message  (Attempt $_failedAttempts/5)',
                style: GoogleFonts.inter(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: NarcSealColors.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showLockoutWarning() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: NarcSealColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: NarcSealColors.resultPositive),
        ),
        icon: const Icon(
          Icons.lock_outlined,
          color: NarcSealColors.resultPositive,
          size: 48,
        ),
        title: Text(
          'ACCOUNT LOCKED',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: NarcSealColors.resultPositive,
          ),
        ),
        content: Text(
          'Too many failed attempts. Account locked for 30 minutes.\n\n'
          'If this persists, contact your District Admin for assistance.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: NarcSealColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isLocked = false;
                _failedAttempts = 0;
              });
            },
            child: Text(
              'Understood',
              style: GoogleFonts.inter(
                color: NarcSealColors.chromeHighlight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBiometric() async {
    HapticFeedback.mediumImpact();
    // In production: local_auth package fingerprint/face scan
    // Mock: just succeed after a brief delay
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NarcSealColors.bgAbyss,
      body: Stack(
        children: [
          // Background video
          Positioned.fill(
            child: BreathingBackground(
              videoAssetPath: 'assets/videos/login_breathing.mp4',
              opacity: 0.8,
              child: const SizedBox.shrink(),
            ),
          ),

          // Main content
          SafeArea(
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                final dx = _shakeController.isAnimating
                    ? _shakeAnimation.value *
                        ((_shakeController.value * 6).floor().isEven ? 1 : -1)
                    : 0.0;
                return Transform.translate(
                  offset: Offset(dx, 0),
                  child: child,
                );
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Shield logo
                    Image.asset(
                      'assets/images/branding/logo_shield.png',
                      width: 80,
                      height: 80,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: NarcSealColors.chromeHighlight,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.shield,
                          color: NarcSealColors.chromeHighlight,
                          size: 40,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // NarcSeal title
                    Text(
                      'NarcSeal',
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: NarcSealColors.chromeHighlight,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Security indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: NarcSealColors.resultNegative,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ZERO TRUST • DEVICE-BOUND • ENCRYPTED',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            color: NarcSealColors.textMuted,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Badge ID field
                    _buildInputField(
                      controller: _badgeController,
                      focusNode: _badgeFocus,
                      icon: Icons.badge_outlined,
                      hint: 'Badge ID (e.g., NCB-4421)',
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_userFocus),
                    ),

                    const SizedBox(height: 16),

                    // Username field
                    _buildInputField(
                      controller: _usernameController,
                      focusNode: _userFocus,
                      icon: Icons.person_outline,
                      hint: 'Username (e.g., ncb.sharma.4421)',
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_passFocus),
                    ),

                    const SizedBox(height: 16),

                    // Password field
                    _buildInputField(
                      controller: _passwordController,
                      focusNode: _passFocus,
                      icon: Icons.lock_outline,
                      hint: 'Password',
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleLogin(),
                    ),

                    const SizedBox(height: 8),

                    // Password policy hint
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Min 8 chars • A-Z • a-z • 0-9 • Special',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: NarcSealColors.textMuted,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // AUTHENTICATE button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: _isSuccess
                              ? const LinearGradient(colors: [
                                  NarcSealColors.resultNegative,
                                  Color(0xFF16A34A),
                                ])
                              : _hasError
                                  ? const LinearGradient(colors: [
                                      NarcSealColors.resultPositive,
                                      Color(0xFFDC2626),
                                    ])
                                  : const LinearGradient(colors: [
                                      NarcSealColors.bgGunmetal,
                                      NarcSealColors.borderSubtle,
                                    ]),
                          boxShadow: [
                            BoxShadow(
                              color: (_isSuccess
                                      ? NarcSealColors.resultNegative
                                      : _hasError
                                          ? NarcSealColors.resultPositive
                                          : NarcSealColors.chromeHighlight)
                                  .withOpacity(0.3),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _isLoading ? null : _handleLogin,
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : _isSuccess
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 28,
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.lock_open,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'AUTHENTICATE',
                                              style: GoogleFonts.orbitron(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // OR divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: NarcSealColors.borderSubtle.withOpacity(0.5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: NarcSealColors.textMuted,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: NarcSealColors.borderSubtle.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Biometric fingerprint button
                    AnimatedBuilder(
                      animation: _biometricPulseAnimation,
                      builder: (context, child) {
                        return GestureDetector(
                          onTap: _handleBiometric,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: NarcSealColors.chromeHighlight.withOpacity(
                                  _biometricPulseAnimation.value,
                                ),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: NarcSealColors.chromeHighlight.withOpacity(
                                    _biometricPulseAnimation.value * 0.3,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.fingerprint,
                              size: 36,
                              color: NarcSealColors.chromeHighlight,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Biometric Login',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: NarcSealColors.textMuted,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Device binding indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: NarcSealColors.bgSurface.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: NarcSealColors.borderSubtle.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone_android,
                            size: 14,
                            color: NarcSealColors.resultNegative,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Device-Bound Authentication',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: NarcSealColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: NarcSealColors.resultNegative,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Footer
                    Text(
                      'Ministry of Home Affairs',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: NarcSealColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Narcotics Control Bureau',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: NarcSealColors.textMuted,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // No sign up notice
                    Text(
                      'Invitation-only access. No self-registration.',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8,
                        color: NarcSealColors.textMuted.withOpacity(0.5),
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    TextInputAction textInputAction = TextInputAction.done,
    ValueChanged<String>? onSubmitted,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: NarcSealColors.bgGunmetal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focusNode.hasFocus
              ? (_hasError
                  ? NarcSealColors.resultPositive
                  : NarcSealColors.chromeHighlight)
              : NarcSealColors.borderSubtle.withOpacity(0.3),
          width: focusNode.hasFocus ? 1.5 : 1,
        ),
        boxShadow: focusNode.hasFocus
            ? [
                BoxShadow(
                  color: (_hasError
                          ? NarcSealColors.resultPositive
                          : NarcSealColors.chromeHighlight)
                      .withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword ? _obscurePassword : false,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: NarcSealColors.textPrimary,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: NarcSealColors.textMuted, size: 20),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                    HapticFeedback.selectionClick();
                  },
                  child: AnimatedRotation(
                    turns: _obscurePassword ? 0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: NarcSealColors.textMuted,
                      size: 20,
                    ),
                  ),
                )
              : null,
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: NarcSealColors.textMuted,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (_) {
          if (_hasError) setState(() => _hasError = false);
        },
      ),
    );
  }
}
