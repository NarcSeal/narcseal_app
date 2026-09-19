import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'pulse_dot.dart';

enum StatusType { sealed, synced, pending }

class StatusChip extends StatelessWidget {
  final StatusType status;
  final bool compact;

  const StatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String label;
    bool needsPulse = false;

    switch (status) {
      case StatusType.sealed:
        icon = Icons.lock;
        color = Colors.green;
        label = 'Sealed';
        break;
      case StatusType.synced:
        icon = Icons.check_circle;
        color = Colors.green;
        label = 'Synced';
        break;
      case StatusType.pending:
        icon = Icons.hourglass_empty;
        color = Colors.amber;
        label = 'Pending';
        needsPulse = true;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: NarcSealColors.bgElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (needsPulse)
            PulseDot(color: color, size: compact ? 6 : 8)
          else
            Icon(icon, size: compact ? 10 : 12, color: color),
          SizedBox(width: compact ? 2 : 4),
          if (!compact)
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 10,
                color: NarcSealColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}
