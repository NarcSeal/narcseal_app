import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../../models/test_result.dart';
import 'status_chip.dart';

class EvidenceCard extends StatefulWidget {
  final TestResult result;
  final String? substance;
  final double confidence;
  final String time;
  final String? date;
  final String location;
  final bool isSynced;
  final bool isSealed;
  final String hash;
  final VoidCallback onTap;

  const EvidenceCard({
    super.key,
    required this.result,
    this.substance,
    required this.confidence,
    required this.time,
    this.date,
    required this.location,
    required this.isSynced,
    required this.isSealed,
    required this.hash,
    required this.onTap,
  });

  @override
  State<EvidenceCard> createState() => _EvidenceCardState();
}

class _EvidenceCardState extends State<EvidenceCard> {
  bool _isPressed = false;

  Color _getResultColor() {
    switch (widget.result) {
      case TestResult.positive: return NarcSealColors.resultPositiveText;
      case TestResult.negative: return NarcSealColors.resultNegativeText;
      case TestResult.inconclusive: return NarcSealColors.resultInconclusiveText;
    }
  }
  
  String _getResultText() {
    switch (widget.result) {
      case TestResult.positive: return 'POSITIVE';
      case TestResult.negative: return 'NEGATIVE';
      case TestResult.inconclusive: return 'INCONCLUSIVE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultColor = _getResultColor();
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _isPressed ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: NarcSealColors.bgGunmetal.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NarcSealColors.borderSubtle.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: _isPressed ? 12 : 8,
              offset: Offset(0, _isPressed ? 4 : 2),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: resultColor, width: 4),
                ),
                color: Colors.white.withOpacity(0.02),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: resultColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getResultText(),
                        style: TextStyle(
                          color: resultColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.confidence.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: NarcSealColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (widget.substance != null)
                    Text(
                      widget.substance!,
                      style: const TextStyle(
                        color: NarcSealColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: NarcSealColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        widget.time,
                        style: const TextStyle(
                          fontFamily: 'Courier', // monospace
                          color: NarcSealColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, size: 14, color: NarcSealColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        widget.location,
                        style: const TextStyle(
                          color: NarcSealColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (widget.isSealed) const StatusChip(status: StatusType.sealed),
                      if (widget.isSealed) const SizedBox(width: 8),
                      if (widget.isSynced) const StatusChip(status: StatusType.synced)
                      else const StatusChip(status: StatusType.pending),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.hash.length > 12 ? '${widget.hash.substring(0, 12)}...' : widget.hash,
                    style: const TextStyle(
                      fontFamily: 'Courier', // monospace
                      color: NarcSealColors.chromeHighlight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
