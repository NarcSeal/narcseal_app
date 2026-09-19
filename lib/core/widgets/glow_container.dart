import 'package:flutter/material.dart';
import '../theme/colors.dart';

class GlowContainer extends StatefulWidget {
  final Widget? child;
  final Color glowColor;
  final double borderWidth;
  final double borderRadius;
  final Duration duration;

  const GlowContainer({
    super.key,
    this.child,
    this.glowColor = NarcSealColors.chromeHighlight,
    this.borderWidth = 1.5,
    this.borderRadius = 16.0,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<GlowContainer> createState() => _GlowContainerState();
}

class _GlowContainerState extends State<GlowContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.glowColor.withOpacity(_glowAnimation.value),
              width: widget.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(_glowAnimation.value * 0.5),
                blurRadius: 12 * _glowAnimation.value,
                spreadRadius: 2 * _glowAnimation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
