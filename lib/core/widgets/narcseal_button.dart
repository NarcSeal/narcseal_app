import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

enum ButtonVariant { primary, danger, ghost }

class NarcSealButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? leadingIcon;
  final bool isLoading;
  final ButtonVariant variant;

  const NarcSealButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.leadingIcon,
    this.isLoading = false,
  }) : variant = ButtonVariant.primary;

  const NarcSealButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.leadingIcon,
    this.isLoading = false,
  }) : variant = ButtonVariant.danger;

  const NarcSealButton.ghost({
    super.key,
    required this.text,
    this.onPressed,
    this.leadingIcon,
    this.isLoading = false,
  }) : variant = ButtonVariant.ghost;

  @override
  State<NarcSealButton> createState() => _NarcSealButtonState();
}

class _NarcSealButtonState extends State<NarcSealButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      HapticFeedback.lightImpact();
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          decoration: _getDecoration(),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              splashColor: _getSplashColor(),
              highlightColor: _getHighlightColor(),
              onTap: widget.isLoading || widget.onPressed == null ? null : () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                        ),
                      )
                    else if (widget.leadingIcon != null) ...[
                      Icon(widget.leadingIcon, color: _getTextColor(), size: 20),
                      const SizedBox(width: 8),
                    ],
                    if (!widget.isLoading || widget.text.isNotEmpty)
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: _getTextColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    final bool isDisabled = widget.onPressed == null;
    
    switch (widget.variant) {
      case ButtonVariant.primary:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Chrome/Silver brushed metal gradient instead of cyan
          gradient: isDisabled
              ? LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade900])
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE0E0E0), Color(0xFF999999)],
                ),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: NarcSealColors.accentCyanGlow, // which is now silver glow
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
        );
      case ButtonVariant.danger:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDisabled ? Colors.grey.shade800 : NarcSealColors.resultPositive,
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: NarcSealColors.resultPositive.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
        );
      case ButtonVariant.ghost:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: NarcSealColors.bgGunmetal,
          border: Border.all(
            color: isDisabled ? Colors.grey.shade800 : NarcSealColors.borderSubtle,
            width: 1,
          ),
        );
    }
  }

  Color _getSplashColor() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return Colors.white.withOpacity(0.4);
      case ButtonVariant.ghost:
        return Colors.white.withOpacity(0.1);
      case ButtonVariant.danger:
        return Colors.black.withOpacity(0.2);
    }
  }
  
  Color _getHighlightColor() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return Colors.white.withOpacity(0.2);
      case ButtonVariant.ghost:
        return Colors.white.withOpacity(0.05);
      case ButtonVariant.danger:
        return Colors.black.withOpacity(0.1);
    }
  }

  Color _getTextColor() {
    if (widget.onPressed == null) return Colors.grey.shade600;
    
    switch (widget.variant) {
      case ButtonVariant.primary:
        return NarcSealColors.bgAbyss; // Dark text on silver button
      case ButtonVariant.danger:
        return NarcSealColors.textPrimary; // White text on dark red button
      case ButtonVariant.ghost:
        return NarcSealColors.chromeHighlight; // Silver text on gunmetal
    }
  }
}

