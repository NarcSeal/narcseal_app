import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/widgets/evidence_card.dart';
import '../models/test_result.dart';
import '../models/evidence_record.dart';
import '../services/api_service.dart';
import '../navigation/app_router.dart';

class FieldLogScreen extends StatefulWidget {
  const FieldLogScreen({super.key});

  @override
  State<FieldLogScreen> createState() => _FieldLogScreenState();
}

class _FieldLogScreenState extends State<FieldLogScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<EvidenceRecord> _allRecords = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;

  static const List<String> _filters = [
    'All',
    'Positive',
    'Negative',
    'Synced',
    'Not Synced',
  ];

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    final records = await ApiService.getRecentRecords();
    if (mounted) {
      setState(() {
        _allRecords = records;
        _isLoading = false;
      });
    }
  }

  void _handleNavTap(int index) {
    if (index == 1) return; // Already on Log
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.stats);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EvidenceRecord> get _filteredRecords {
    if (_selectedFilter == 'All') return _allRecords;
    if (_selectedFilter == 'Synced') return _allRecords.where((r) => r.isSynced).toList();
    if (_selectedFilter == 'Not Synced') return _allRecords.where((r) => !r.isSynced).toList();
    
    final filterResult = _selectedFilter == 'Positive' 
        ? TestResult.positive 
        : (_selectedFilter == 'Negative' ? TestResult.negative : TestResult.inconclusive);
        
    return _allRecords.where((r) => r.testResult == filterResult).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NarcSealColors.warmOffWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text('FIELD LOG'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter chips
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return ChoiceChip(
                    label: Text(
                      filter,
                      style: NarcSealTypography.label.copyWith(
                        color: isSelected ? NarcSealColors.white : NarcSealColors.graphite,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedFilter = filter);
                      }
                    },
                    selectedColor: NarcSealColors.olive,
                    backgroundColor: NarcSealColors.white,
                    side: BorderSide(
                      color: isSelected ? NarcSealColors.olive : NarcSealColors.lightBeige,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                },
              ),
            ),
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: NarcSealColors.olive))
                  : _filteredRecords.isEmpty
                      ? Center(
                          child: Text('No records found.', style: NarcSealTypography.body),
                        )
                      : RefreshIndicator(
                          color: NarcSealColors.olive,
                          onRefresh: _fetchRecords,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _filteredRecords.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final record = _filteredRecords[index];
                              return EvidenceCard(
                                result: record.testResult,
                                substance: record.substance,
                                confidence: record.confidence,
                                time: record.formattedTime,
                                date: record.formattedDate,
                                location: record.address ?? record.gpsString,
                                isSynced: record.isSynced,
                                isSealed: record.isSealed,
                                hash: record.recordHash,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pushNamed(context, AppRoutes.testDetails, arguments: record);
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Log is index 1
        onTap: _handleNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Log'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
