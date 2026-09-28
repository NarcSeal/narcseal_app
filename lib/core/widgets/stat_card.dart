import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class StatCard extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: NarcSealColors.titaniumGray,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: NarcSealTypography.importantNumbers,
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: NarcSealTypography.label.copyWith(
            fontSize: 10,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
