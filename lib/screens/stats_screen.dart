import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../navigation/app_router.dart';
import '../services/api_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Map<String, dynamic>> _breakdown = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final breakdown = await ApiService.getSubstanceBreakdown();
    if (mounted) {
      setState(() {
        _breakdown = breakdown;
        _isLoading = false;
      });
    }
  }

  void _handleNavTap(BuildContext context, int index) {
    if (index == 2) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.fieldLog);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NarcSealColors.warmOffWhite,
      appBar: AppBar(
        title: const Text('STATISTICS'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/images/branding/narcseal_logo.png',
              height: 28,
              errorBuilder: (c, e, s) => const Icon(Icons.security, color: NarcSealColors.titaniumGray),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: NarcSealColors.olive))
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Substance Breakdown', style: NarcSealTypography.screenTitle),
                    const SizedBox(height: 16),
                    if (_breakdown.isEmpty)
                      Text('No data available', style: NarcSealTypography.body)
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: _breakdown.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = _breakdown[index];
                            return ListTile(
                              leading: const Icon(Icons.science, color: NarcSealColors.olive),
                              title: Text(item['substance'].toString(), style: NarcSealTypography.body),
                              trailing: Text(
                                item['count'].toString(), 
                                style: NarcSealTypography.body.copyWith(fontWeight: FontWeight.bold)
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Stats is index 2
        onTap: (index) => _handleNavTap(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Log'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
