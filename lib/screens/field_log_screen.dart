import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/colors.dart';
import '../core/widgets/evidence_card.dart';
import '../core/widgets/pulse_dot.dart';
import '../services/mock_data_service.dart';
import '../models/test_result.dart';

/// Screen 7: Field Log — searchable, filterable test history.
///
/// Features:
/// - Search bar with voice input icon
/// - Horizontal filter chips (All, Positive, Negative, Inconclusive, Unsynced)
/// - Date separators between groups
/// - Staggered entrance animation for evidence cards
/// - Pull-to-refresh with logo spin
/// - Empty state illustration
class FieldLogScreen extends StatefulWidget {
  const FieldLogScreen({super.key});

  @override
  State<FieldLogScreen> createState() => _FieldLogScreenState();
}

class _FieldLogScreenState extends State<FieldLogScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  late AnimationController _staggerController;

  static const List<String> _filters = [
    'All',
    'Positive',
    'Negative',
    'Inconclusive',
    'Unsynced',
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  List<dynamic> get _filteredRecords {
    final records = MockDataService.recentRecords;
    if (_selectedFilter == 'All') return records;
    if (_selectedFilter == 'Unsynced') {
      return records.where((r) => !r.isSynced).toList();
    }
    final filterResult = switch (_selectedFilter) {
      'Positive' => TestResult.positive,
      'Negative' => TestResult.negative,
      'Inconclusive' => TestResult.inconclusive,
      _ => null,
    };
    if (filterResult == null) return records;
    return records.where((r) => r.testResult == filterResult).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _filteredRecords;

    return Scaffold(
      backgroundColor: NarcSealColors.bgAbyss,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Field Log',
                    style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: NarcSealColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      // Record count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: NarcSealColors.bgElevated,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${filteredRecords.length} records',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: NarcSealColors.accentCyan,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.tune,
                          color: NarcSealColors.textSecondary,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: NarcSealColors.bgElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: NarcSealColors.borderSubtle,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: NarcSealColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by location, substance, ID...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: NarcSealColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: NarcSealColors.textMuted,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.mic_outlined,
                        color: NarcSealColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  final chipColor = switch (filter) {
                    'Positive' => NarcSealColors.resultPositive,
                    'Negative' => NarcSealColors.resultNegative,
                    'Inconclusive' => NarcSealColors.resultInconclusive,
                    'Unsynced' => NarcSealColors.chainPurple,
                    _ => NarcSealColors.accentCyan,
                  };

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedFilter = filter);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? chipColor.withOpacity(0.15)
                            : NarcSealColors.bgSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? chipColor
                              : NarcSealColors.borderSubtle,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected && filter != 'All')
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: PulseDot(
                                color: chipColor,
                                size: 6,
                              ),
                            ),
                          Text(
                            filter,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? chipColor
                                  : NarcSealColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Records list
            Expanded(
              child: filteredRecords.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: NarcSealColors.accentCyan,
                      backgroundColor: NarcSealColors.bgSurface,
                      onRefresh: () async {
                        HapticFeedback.mediumImpact();
                        await Future.delayed(
                          const Duration(milliseconds: 1500),
                        );
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        itemCount: filteredRecords.length,
                        itemBuilder: (context, index) {
                          final record = filteredRecords[index];

                          // Date separator
                          Widget? dateSeparator;
                          if (index == 0 ||
                              record.formattedDate !=
                                  filteredRecords[index - 1].formattedDate) {
                            dateSeparator = Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: NarcSealColors.borderSubtle
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      record.formattedDate,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: NarcSealColors.textMuted,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: NarcSealColors.borderSubtle
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Staggered entrance animation
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(
                              milliseconds: 400 + (index * 100),
                            ),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (dateSeparator != null) dateSeparator,
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: EvidenceCard(
                                    result: record.testResult,
                                    substance: record.substance,
                                    confidence: record.confidence,
                                    time: record.formattedTime,
                                    date: record.formattedDate,
                                    location: record.address ??
                                        record.gpsString,
                                    isSynced: record.isSynced,
                                    isSealed: record.isSealed,
                                    hash: record.recordHash,
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Empty state illustration placeholder
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: NarcSealColors.bgSurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: NarcSealColors.borderSubtle,
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.biotech,
              size: 48,
              color: NarcSealColors.chromeHighlight,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No tests recorded yet',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: NarcSealColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap NEW TEST on the home screen to begin',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: NarcSealColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          // Animated arrow pointing up
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -8 * (0.5 + 0.5 * (value * 3.14159).sin())),
                child: child,
              );
            },
            child: Icon(
              Icons.arrow_upward,
              color: NarcSealColors.accentCyan.withOpacity(0.5),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to use sin on double (minimal math)
extension on double {
  double sin() => _sin(this);
}

double _sin(double x) {
  // Simple sine approximation for animation
  x = x % (2 * 3.14159265);
  double result = x;
  double term = x;
  for (int i = 1; i < 7; i++) {
    term *= -x * x / ((2 * i) * (2 * i + 1));
    result += term;
  }
  return result;
}
