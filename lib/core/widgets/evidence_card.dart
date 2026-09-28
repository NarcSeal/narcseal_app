import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../../models/test_result.dart';
import 'status_chip.dart';

class EvidenceCard extends StatelessWidget {
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

  Color _getResultColor() {
    switch (result) {
      case TestResult.positive:
        return NarcSealColors.positive;
      case TestResult.negative:
        return NarcSealColors.negative;
      case TestResult.inconclusive:
        return NarcSealColors.inconclusive;
    }
  }

  String _getResultText() {
    switch (result) {
      case TestResult.positive:
        return 'POSITIVE';
      case TestResult.negative:
        return 'NEGATIVE';
      case TestResult.inconclusive:
        return 'INCONCLUSIVE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultColor = _getResultColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: NarcSealColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NarcSealColors.lightBeige),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: resultColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getResultText(),
                  style: NarcSealTypography.statusBadge.copyWith(
                    color: resultColor,
                  ),
                ),
                const Spacer(),
                if (result != TestResult.inconclusive)
                  Text(
                    '${confidence.toStringAsFixed(1)}%',
                    style: NarcSealTypography.importantNumbers.copyWith(
                      fontSize: 16,
                    ),
                  ),
                if (result == TestResult.inconclusive)
                  const Icon(Icons.remove, size: 16, color: NarcSealColors.graphite),
              ],
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  substance ?? 'Unknown',
                  style: NarcSealTypography.sectionTitle.copyWith(
                    fontSize: 18,
                  ),
                ),
                const Icon(Icons.more_vert, size: 20, color: NarcSealColors.graphite),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: NarcSealColors.graphite),
                const SizedBox(width: 4),
                Text(
                  date != null ? '$date • $time' : time,
                  style: NarcSealTypography.metadata,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: NarcSealColors.graphite),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: NarcSealTypography.metadata,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (isSealed) const StatusChip(status: StatusType.sealed),
                if (isSealed) const SizedBox(width: 8),
                if (isSynced)
                  const StatusChip(status: StatusType.synced)
                else
                  const StatusChip(status: StatusType.pending),
                const Spacer(),
                Text(
                  'ID: ${hash.length > 12 ? hash.substring(0, 12) : hash}',
                  style: NarcSealTypography.metadata.copyWith(
                    color: NarcSealColors.titaniumGray,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
