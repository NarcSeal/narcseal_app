import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ScanLine extends StatefulWidget {
  final double height;
  final Color color;
  final Duration duration;

  const ScanLine({
    super.key,
    required this.height,
    this.color = NarcSealColors.chromeHighlight,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<ScanLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
    _animation = Tween<double>(begin: 0, end: widget.height).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: _animation.value,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: const Size(double.infinity, 20),
            painter: _ScanLinePainter(color: widget.color),
          ),
        );
      },
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final Color color;

  _ScanLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          color.withOpacity(0.5),
          color,
          color.withOpacity(0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
    
    // Solid line in the middle
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
