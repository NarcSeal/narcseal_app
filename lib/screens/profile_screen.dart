import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/widgets/stat_card.dart';
import '../services/api_service.dart';
import '../navigation/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isNotificationsOn = true;
  String _language = 'EN';
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final officer = ApiService.currentOfficer;
    final stats = await ApiService.getOfficerStats(officer.badgeId);
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  void _handleNavTap(int index) {
    if (index == 3) return; // Already on Profile
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.fieldLog);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.stats); // If it exists
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final officer = ApiService.currentOfficer;

    return Scaffold(
      backgroundColor: NarcSealColors.warmOffWhite,
      appBar: AppBar(
        title: const Text('PROFILE'),
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
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: NarcSealColors.lightBeige,
                  border: Border.all(color: NarcSealColors.paleOlive, width: 2),
                ),
                child: const Icon(Icons.person, size: 48, color: NarcSealColors.titaniumGray),
              ),
              const SizedBox(height: 16),
              
              // Name and Badge
              Text(
                officer.fullName,
                style: NarcSealTypography.screenTitle,
              ),
              const SizedBox(height: 4),
              Text(
                'Badge: ${officer.badgeId}',
                style: NarcSealTypography.metadata.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              
              // Rank and Location
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildChip(Icons.military_tech, officer.rank.replaceAll('_', ' ').toUpperCase()),
                  const SizedBox(width: 8),
                  _buildChip(Icons.location_on_outlined, '${officer.district}, ${officer.state}'),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Stats
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      value: (_stats?['total_tests'] ?? 0).toDouble(),
                      label: 'TOTAL TESTS',
                      icon: Icons.science_outlined,
                    ),
                  ),
                  Container(width: 1, height: 40, color: NarcSealColors.paleOlive),
                  Expanded(
                    child: StatCard(
                      value: 98, // Mock accuracy
                      label: 'ACCURACY %',
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      value: (_stats?['positive_count'] ?? 0).toDouble(),
                      label: 'POSITIVE',
                      icon: Icons.warning_amber_rounded,
                    ),
                  ),
                  Container(width: 1, height: 40, color: NarcSealColors.paleOlive),
                  Expanded(
                    child: StatCard(
                      value: 1, // Mock days active
                      label: 'DAYS ACTIVE',
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Settings', style: NarcSealTypography.sectionTitle),
              ),
              const SizedBox(height: 16),
              
              // Settings List
              Container(
                decoration: BoxDecoration(
                  color: NarcSealColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NarcSealColors.lightBeige),
                ),
                child: Column(
                  children: [
                    _buildToggleSetting(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      value: _isNotificationsOn,
                      onChanged: (val) {
                        setState(() => _isNotificationsOn = val);
                      },
                    ),
                    const Divider(height: 1),
                    _buildActionSetting(
                      icon: Icons.language,
                      label: 'Language',
                      trailingText: _language,
                      onTap: () {
                        setState(() {
                          _language = _language == 'EN' ? 'HI' : 'EN';
                        });
                      },
                    ),
                    const Divider(height: 1),
                    _buildActionSetting(
                      icon: Icons.lock_outline,
                      label: 'Change Password',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              OutlinedButton(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, size: 20, color: NarcSealColors.negative),
                    const SizedBox(width: 12),
                    Text('LOGOUT', style: NarcSealTypography.buttonText.copyWith(color: NarcSealColors.negative)),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              Text(
                'NarcSeal v2.0.0 (SIH26231)\nMinistry of Home Affairs • NCB',
                style: NarcSealTypography.metadata,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Profile is index 3
        onTap: _handleNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Log'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: NarcSealColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: NarcSealColors.lightBeige),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: NarcSealColors.graphite),
          const SizedBox(width: 4),
          Text(label, style: NarcSealTypography.metadata.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildToggleSetting({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: NarcSealColors.graphite),
      title: Text(label, style: NarcSealTypography.body),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: NarcSealColors.olive,
      ),
    );
  }

  Widget _buildActionSetting({
    required IconData icon,
    required String label,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: NarcSealColors.graphite),
      title: Text(label, style: NarcSealTypography.body),
      trailing: trailingText != null
          ? Text(trailingText, style: NarcSealTypography.metadata.copyWith(fontWeight: FontWeight.bold))
          : const Icon(Icons.chevron_right, color: NarcSealColors.titaniumGray),
    );
  }
}
