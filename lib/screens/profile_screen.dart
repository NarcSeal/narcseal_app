import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/colors.dart';
import '../core/widgets/stat_card.dart';
import '../services/api_service.dart';
import '../navigation/app_router.dart';

/// Screen 8: Officer Profile — identity, stats, and settings.
///
/// Features:
/// - Officer photo with cyan border ring
/// - Name, badge (monospace cyan), station, rank
/// - 4 stat cards in 2×2 grid: Total Tests, Accuracy, Positive Found, Days Active
/// - Settings section with toggles and navigation items
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = true;
  bool _isNotificationsOn = true;
  String _language = 'EN';

  @override
  Widget build(BuildContext context) {
    final officer = ApiService.currentOfficer;

    return Scaffold(
      backgroundColor: NarcSealColors.bgAbyss,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Header with back button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: NarcSealColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'Profile',
                    style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: NarcSealColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),

              const SizedBox(height: 32),

              // Officer photo placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NarcSealColors.accentCyan,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: NarcSealColors.accentCyan.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 47,
                  backgroundColor: NarcSealColors.bgElevated,
                  child: Icon(
                    Icons.person,
                    size: 48,
                    color: NarcSealColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Officer name
              Text(
                officer.fullName,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: NarcSealColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              // Badge ID in monospace cyan
              Text(
                officer.badgeId,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  color: NarcSealColors.accentCyan,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 8),

              // Rank + Station
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildInfoChip(
                    Icons.military_tech,
                    officer.rank.replaceAll('_', ' ').toUpperCase(),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.location_on_outlined,
                    '${officer.district}, ${officer.state}',
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Station code
              Text(
                'Station: ${officer.stationCode}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: NarcSealColors.textMuted,
                ),
              ),

              const SizedBox(height: 32),

              // Stats grid (2×2)
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      value: 2, // Default since no stat endpoint yet
                      label: 'TOTAL TESTS',
                      accentColor: NarcSealColors.chromeHighlight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      value: 100,
                      label: 'ACCURACY %',
                      accentColor: NarcSealColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      value: 1,
                      label: 'POSITIVE',
                      accentColor: NarcSealColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      value: 1,
                      label: 'DAYS ACTIVE',
                      accentColor: NarcSealColors.accentCyan,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Settings section
              _buildSectionHeader('Settings'),
              const SizedBox(height: 12),

              // Dark Mode toggle
              _buildToggleSetting(
                icon: Icons.dark_mode,
                label: 'Dark Mode',
                sublabel: 'Monochromatic dark interface',
                value: _isDarkMode,
                activeColor: NarcSealColors.chromeHighlight,
                onChanged: (val) {
                  HapticFeedback.mediumImpact();
                  setState(() => _isDarkMode = val);
                },
              ),

              _buildDivider(),

              // Language toggle
              _buildTapSetting(
                icon: Icons.language,
                label: 'Language',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: NarcSealColors.bgElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: NarcSealColors.borderSubtle,
                    ),
                  ),
                  child: Text(
                    _language,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: NarcSealColors.accentCyan,
                    ),
                  ),
                ),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _language = _language == 'EN' ? 'HI' : 'EN';
                  });
                },
              ),

              _buildDivider(),

              // Notifications toggle
              _buildToggleSetting(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                sublabel: 'Alert sounds and vibrations',
                value: _isNotificationsOn,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() => _isNotificationsOn = val);
                },
              ),

              _buildDivider(),

              // Device Info
              _buildTapSetting(
                icon: Icons.phone_android,
                label: 'Device Info',
                trailing: const Icon(
                  Icons.chevron_right,
                  color: NarcSealColors.textMuted,
                  size: 20,
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showDeviceInfoDialog();
                },
              ),

              _buildDivider(),

              // Change Password
              _buildTapSetting(
                icon: Icons.lock_outline,
                label: 'Change Password',
                trailing: const Icon(
                  Icons.chevron_right,
                  color: NarcSealColors.textMuted,
                  size: 20,
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                },
              ),

              const SizedBox(height: 24),

              // Logout button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NarcSealColors.textPrimary,
                    side: const BorderSide(
                      color: NarcSealColors.borderSubtle,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.logout, size: 20),
                  label: Text(
                    'Logout',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // App version
              Text(
                'NarcSeal v1.0.0 (SIH26231)',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: NarcSealColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ministry of Home Affairs • NCB',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: NarcSealColors.textMuted,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: NarcSealColors.bgElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: NarcSealColors.textMuted),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: NarcSealColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: NarcSealColors.textMuted,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildToggleSetting({
    required IconData icon,
    required String label,
    String? sublabel,
    required bool value,
    Color activeColor = NarcSealColors.accentCyan,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: NarcSealColors.textSecondary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: NarcSealColors.textPrimary,
                  ),
                ),
                if (sublabel != null)
                  Text(
                    sublabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: NarcSealColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: activeColor,
            activeTrackColor: activeColor.withOpacity(0.3),
            inactiveThumbColor: NarcSealColors.textMuted,
            inactiveTrackColor: NarcSealColors.bgElevated,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTapSetting({
    required IconData icon,
    required String label,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: NarcSealColors.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: NarcSealColors.textPrimary,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: NarcSealColors.borderSubtle.withOpacity(0.3),
    );
  }

  void _showDeviceInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NarcSealColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: NarcSealColors.borderSubtle,
          ),
        ),
        title: Text(
          'Device Info',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: NarcSealColors.accentCyan,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _deviceInfoRow('Device ID', 'PIXEL-7A-001'),
            _deviceInfoRow('OS', 'Android 14'),
            _deviceInfoRow('App Version', '1.0.0'),
            _deviceInfoRow('Build', 'SIH26231-release'),
            _deviceInfoRow('Last Sync', '18 Sep 2026, 14:32'),
            _deviceInfoRow('Local Records', '247'),
            _deviceInfoRow('Storage Used', '142 MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: GoogleFonts.inter(
                color: NarcSealColors.accentCyan,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviceInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: NarcSealColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: NarcSealColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
