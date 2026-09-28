import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeService _themeService = ThemeService();
  bool _autoSync = true;
  bool _locationTagging = true;
  bool _saveToDevice = true;
  bool _biometricLogin = false;

  void _onNightOpsToggled(bool value) {
    HapticFeedback.lightImpact();
    _themeService.setNightOps(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NarcSealColors.warmOffWhite,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          _buildSectionHeader('General'),
          ListTile(
            leading: const Icon(Icons.language, color: NarcSealColors.graphite),
            title: Text('Language', style: NarcSealTypography.body),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('English', style: NarcSealTypography.metadata.copyWith(fontSize: 14)),
                const Icon(Icons.chevron_right, color: NarcSealColors.graphite),
              ],
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined, color: NarcSealColors.graphite),
            title: Text('Night Ops Mode', style: NarcSealTypography.body),
            subtitle: Text('Covert operations theme', style: NarcSealTypography.metadata),
            trailing: Switch(
              value: _themeService.isNightOps,
              onChanged: _onNightOpsToggled,
              activeColor: NarcSealColors.olive,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.sync, color: NarcSealColors.graphite),
            title: Text('Auto Sync', style: NarcSealTypography.body),
            trailing: Switch(
              value: _autoSync,
              onChanged: (val) => setState(() => _autoSync = val),
              activeColor: NarcSealColors.olive,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined, color: NarcSealColors.graphite),
            title: Text('Location Tagging', style: NarcSealTypography.body),
            trailing: Switch(
              value: _locationTagging,
              onChanged: (val) => setState(() => _locationTagging = val),
              activeColor: NarcSealColors.olive,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.save_alt_outlined, color: NarcSealColors.graphite),
            title: Text('Save to Device', style: NarcSealTypography.body),
            subtitle: Text('Keep a local copy', style: NarcSealTypography.metadata),
            trailing: Switch(
              value: _saveToDevice,
              onChanged: (val) => setState(() => _saveToDevice = val),
              activeColor: NarcSealColors.olive,
            ),
          ),
          const Divider(height: 32),
          _buildSectionHeader('Security'),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: NarcSealColors.graphite),
            title: Text('Change Password', style: NarcSealTypography.body),
            trailing: const Icon(Icons.chevron_right, color: NarcSealColors.graphite),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint, color: NarcSealColors.graphite),
            title: Text('Biometric Login', style: NarcSealTypography.body),
            trailing: Switch(
              value: _biometricLogin,
              onChanged: (val) => setState(() => _biometricLogin = val),
              activeColor: NarcSealColors.olive,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined, color: NarcSealColors.graphite),
            title: Text('Auto Logout', style: NarcSealTypography.body),
            subtitle: Text('After 10 minutes', style: NarcSealTypography.metadata),
            trailing: const Icon(Icons.chevron_right, color: NarcSealColors.graphite),
            onTap: () {},
          ),
          const Divider(height: 32),
          _buildSectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: NarcSealColors.positive), // Use positive red for destructive action as per palette
            title: Text('Clear Local Data', style: NarcSealTypography.body.copyWith(color: NarcSealColors.positive)),
            trailing: const Icon(Icons.chevron_right, color: NarcSealColors.graphite),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: NarcSealTypography.sectionTitle.copyWith(
          fontSize: 16,
          color: NarcSealColors.titaniumGray,
        ),
      ),
    );
  }
}
