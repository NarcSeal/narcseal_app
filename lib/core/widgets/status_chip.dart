import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

enum StatusType { sealed, synced, pending }

class StatusChip extends StatelessWidget {
  final StatusType status;

  const StatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;
    Color color;

    switch (status) {
      case StatusType.sealed:
        icon = Icons.lock_outline;
        label = 'Sealed';
        color = NarcSealColors.titaniumGray;
        break;
      case StatusType.synced:
        icon = Icons.sync;
        label = 'Synced';
        color = NarcSealColors.titaniumGray;
        break;
      case StatusType.pending:
        icon = Icons.sync_disabled;
        label = 'Not Synced';
        color = NarcSealColors.graphite;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: NarcSealColors.warmOffWhite,
        border: Border.all(color: NarcSealColors.paleOlive),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: NarcSealTypography.metadata.copyWith(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
