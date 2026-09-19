import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'dart:math' as math;

enum ShimmerType { card, statCard, text, image }

class ShimmerLoading extends StatefulWidget {
  final ShimmerType type;
  
  const ShimmerLoading.card({super.key}) : type = ShimmerType.card;
  const ShimmerLoading.statCard({super.key}) : type = ShimmerType.statCard;
  const ShimmerLoading.text({super.key}) : type = ShimmerType.text;
  const ShimmerLoading.image({super.key}) : type = ShimmerType.image;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.3 + 0.4 * (0.5 * (1 + math.sin(_controller.value * 2 * math.pi)));
        return Container(
          decoration: BoxDecoration(
            color: NarcSealColors.borderSubtle.withOpacity(opacity),
            borderRadius: BorderRadius.circular(_getBorderRadius()),
          ),
          width: _getWidth(),
          height: _getHeight(),
        );
      },
    );
  }

  double _getBorderRadius() {
    switch (widget.type) {
      case ShimmerType.card:
      case ShimmerType.statCard:
      case ShimmerType.image:
        return 16.0;
      case ShimmerType.text:
        return 8.0;
    }
  }
  
  double? _getWidth() {
    switch (widget.type) {
      case ShimmerType.card: return double.infinity;
      case ShimmerType.statCard: return 120;
      case ShimmerType.text: return 150;
      case ShimmerType.image: return 100;
    }
  }
  
  double? _getHeight() {
    switch (widget.type) {
      case ShimmerType.card: return 120;
      case ShimmerType.statCard: return 80;
      case ShimmerType.text: return 16;
      case ShimmerType.image: return 100;
    }
  }
}
