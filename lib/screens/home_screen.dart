import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/colors.dart';
import '../core/widgets/stat_card.dart';
import '../core/widgets/evidence_card.dart';
import '../services/mock_data_service.dart';
import '../services/api_service.dart';
import '../models/evidence_record.dart';
import '../models/officer.dart';
import '../navigation/app_router.dart';
import '../core/widgets/breathing_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotateController;
  
  List<EvidenceRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  Future<void> _fetchData() async {
    final records = await ApiService.getRecentRecords();
    if (mounted) {
      setState(() {
        _records = records;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _handleNewTest() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/test-setup');
  }

  void _handleNavTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 1:
        Navigator.pushNamed(context, AppRoutes.fieldLog);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final officer = ApiService.currentOfficer;
    final records = _records;

    final todayTestCount = _records.where((r) {
      final now = DateTime.now();
      return r.timestamp.year == now.year &&
             r.timestamp.month == now.month &&
             r.timestamp.day == now.day;
    }).length;

    final pendingSyncCount = _records.where((r) => !r.isSynced).length;

    return Scaffold(
      backgroundColor: NarcSealColors.bgAbyss,
      body: Stack(
        children: [
          // Background Video
          Positioned.fill(
            child: BreathingBackground(
              videoAssetPath: 'assets/videos/home_shield_breathing.mp4',
              opacity: 0.6,
              child: const SizedBox.shrink(),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NarcSeal',
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: NarcSealColors.chromeHighlight,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: NarcSealColors.textPrimary,
                            ),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.profile,
                            ),
                            child: const CircleAvatar(
                              radius: 18,
                              backgroundColor: NarcSealColors.borderSubtle,
                              child: Icon(
                                Icons.person,
                                color: NarcSealColors.textSecondary,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Greeting
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${MockDataService.greeting}, ${officer.shortTitle}',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: NarcSealColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Badge: ${officer.badgeId}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          color: NarcSealColors.chromeHighlight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stat Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          value: todayTestCount,
                          label: "TODAY'S TESTS",
                          accentColor: NarcSealColors.chromeHighlight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          value: pendingSyncCount,
                          label: 'PENDING SYNCS',
                          isPending: true,
                          accentColor: NarcSealColors.resultInconclusive,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Hero Button — NEW TEST
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return GestureDetector(
                        onTapDown: (_) => HapticFeedback.lightImpact(),
                        onTap: _handleNewTest,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [NarcSealColors.bgGunmetal, NarcSealColors.borderSubtle],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: NarcSealColors.chromeHighlight
                                    .withOpacity(_pulseAnimation.value),
                                blurRadius: 20,
                                spreadRadius: 4,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _rotateController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: (sin(_rotateController.value * pi * 2) *
                                            5) *
                                        pi /
                                        180,
                                    child: const Icon(
                                      Icons.science,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'NEW TEST',
                                style: GoogleFonts.orbitron(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Recent Tests Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Tests',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: NarcSealColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.fieldLog),
                        child: Text(
                          'View All →',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: NarcSealColors.chromeHighlight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Evidence Cards List
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: NarcSealColors.chromeHighlight))
                    : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 500 + (index * 100)),
                        curve: Curves.easeOutQuart,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: EvidenceCard(
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
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: NarcSealColors.bgSurface,
          border: Border(
            top: BorderSide(color: NarcSealColors.borderSubtle, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: NarcSealColors.chromeHighlight,
          unselectedItemColor: NarcSealColors.textMuted,
          onTap: _handleNavTap,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_outlined), label: 'Log'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined), label: 'Stats'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
