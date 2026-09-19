import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class StatCard extends StatefulWidget {
  final int value;
  final String label;
  final bool isPending;
  final Color accentColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.isPending = false,
    this.accentColor = NarcSealColors.chromeHighlight,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> with TickerProviderStateMixin {
  late AnimationController _countController;
  late Animation<double> _countAnimation;
  late AnimationController _pulseController;
  
  int _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _countAnimation = Tween<double>(begin: 0, end: widget.value.toDouble()).animate(
      CurvedAnimation(parent: _countController, curve: Curves.easeOutCubic),
    );
    _countController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(StatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _countAnimation = Tween<double>(
        begin: _oldValue.toDouble(),
        end: widget.value.toDouble(),
      ).animate(
        CurvedAnimation(parent: _countController, curve: Curves.easeOutCubic),
      );
      _countController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showPulse = widget.isPending && widget.value > 0;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.accentColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: NarcSealColors.bgSurface.withOpacity(0.8),
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _countAnimation,
                      builder: (context, child) {
                        return Text(
                          _countAnimation.value.toInt().toString(),
                          style: const TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: NarcSealColors.textPrimary,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: NarcSealColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (showPulse)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: FadeTransition(
                      opacity: _pulseController,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: NarcSealColors.chromeHighlight,
                          boxShadow: [
                            BoxShadow(
                              color: NarcSealColors.chromeHighlight.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
