import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/widgets/stat_card.dart';
import '../core/widgets/evidence_card.dart';
import '../services/api_service.dart';
import '../models/evidence_record.dart';
import '../navigation/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<EvidenceRecord> _records = [];
  bool _isLoading = true;

  Map<String, dynamic>? _dashboardStats;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final records = await ApiService.getRecentRecords();
    final stats = await ApiService.getDashboardStats();
    if (mounted) {
      setState(() {
        _records = records;
        _dashboardStats = stats;
        _isLoading = false;
      });
    }
  }

  void _handleNavTap(int index) {
    if (index == _currentIndex) return;
    switch (index) {
      case 0:
        // Already home
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.fieldLog);
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
  Widget build(BuildContext context) {
    final officer = ApiService.currentOfficer;
    final records = _records;

    final todayTestCount = _dashboardStats?['total_tests_today'] ?? 0;
    final pendingSyncCount = _dashboardStats?['pending_syncs'] ?? 0;

    return Scaffold(
      backgroundColor: NarcSealColors.warmOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {}, // Drawer placeholder
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/branding/narcseal_logo.png',
                        height: 24,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.security, size: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NarcSeal',
                        style: NarcSealTypography.screenTitle,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () {},
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: NarcSealColors.lightBeige,
                          child: Icon(Icons.person_outline, size: 18, color: NarcSealColors.titaniumGray),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                color: NarcSealColors.olive,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting row with Emblem
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good Morning, ${officer.shortTitle}',
                                style: NarcSealTypography.screenTitle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Badge : ${officer.badgeId}',
                                style: NarcSealTypography.metadata,
                              ),
                            ],
                          ),
                          // Placeholder for emblem
                          const Icon(Icons.account_balance, size: 36, color: NarcSealColors.policeKhaki),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Stat Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: StatCard(
                              value: todayTestCount,
                              label: 'TESTS TODAY',
                              icon: Icons.science_outlined,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: NarcSealColors.paleOlive,
                          ),
                          Expanded(
                            child: StatCard(
                              value: pendingSyncCount,
                              label: 'PENDING SYNCS',
                              icon: Icons.sync,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // New Test Button
                      ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pushNamed(context, AppRoutes.testSetup);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.science_outlined, size: 20),
                            const SizedBox(width: 12),
                            Text('NEW TEST', style: NarcSealTypography.buttonText),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Recent Tests Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Tests', style: NarcSealTypography.sectionTitle),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.fieldLog),
                            child: Row(
                              children: [
                                Text(
                                  'View All',
                                  style: NarcSealTypography.label.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward, size: 14, color: NarcSealColors.titaniumGray),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // List of tests
                      if (_isLoading)
                        const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: NarcSealColors.olive)))
                      else if (records.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text('No recent tests.', style: NarcSealTypography.body),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: records.length > 5 ? 5 : records.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final record = records[index];
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
                                Navigator.pushNamed(context, AppRoutes.testDetails, arguments: record);
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Log'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
