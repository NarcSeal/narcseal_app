import 'package:flutter/material.dart';
import '../theme/colors.dart';

enum CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

class ScannerCorner extends StatefulWidget {
  final CornerPosition position;
  final bool isDetected;
  final double size;
  final Color color;

  const ScannerCorner({
    super.key,
    required this.position,
    this.isDetected = false,
    this.size = 40.0,
    this.color = NarcSealColors.borderSubtle,
  });

  @override
  State<ScannerCorner> createState() => _ScannerCornerState();
}

class _ScannerCornerState extends State<ScannerCorner> with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _breatheAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breatheAnimation,
      builder: (context, child) {
        final currentColor = widget.isDetected ? NarcSealColors.chromeHighlight : widget.color;
        return CustomPaint(
          size: Size(widget.size + _breatheAnimation.value, widget.size + _breatheAnimation.value),
          painter: _CornerPainter(
            position: widget.position,
            color: currentColor,
            strokeWidth: 4.0,
          ),
        );
      },
    );
  }
}

class _CornerPainter extends CustomPainter {
  final CornerPosition position;
  final Color color;
  final double strokeWidth;

  _CornerPainter({
    required this.position,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final shadowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = strokeWidth + 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final path = Path();

    switch (position) {
      case CornerPosition.topLeft:
        path.moveTo(0, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
        // Crosshair line
        path.moveTo(size.width / 2, size.height / 2);
        path.lineTo(size.width / 2 + 10, size.height / 2 + 10);
        break;
      case CornerPosition.topRight:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.moveTo(size.width / 2, size.height / 2);
        path.lineTo(size.width / 2 - 10, size.height / 2 + 10);
        break;
      case CornerPosition.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.moveTo(size.width / 2, size.height / 2);
        path.lineTo(size.width / 2 + 10, size.height / 2 - 10);
        break;
      case CornerPosition.bottomRight:
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.moveTo(size.width / 2, size.height / 2);
        path.lineTo(size.width / 2 - 10, size.height / 2 - 10);
        break;
    }

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
