import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../navigation/app_router.dart';
import '../models/test_kit.dart';
import '../services/api_service.dart';

class TestSetupScreen extends StatefulWidget {
  const TestSetupScreen({super.key});

  @override
  State<TestSetupScreen> createState() => _TestSetupScreenState();
}

class _TestSetupScreenState extends State<TestSetupScreen> {
  TestKit? _selectedKit;
  bool _timerActive = false;
  int _countdown = 0;
  Timer? _timer;
  bool _isLoading = true;
  List<TestKit> _kits = [];

  final TextEditingController _sampleIdController = TextEditingController(text: 'NS-2026-004282');
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchKits();
  }

  Future<void> _fetchKits() async {
    final kits = await ApiService.getTestKits();
    if (mounted) {
      setState(() {
        _kits = kits;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sampleIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_selectedKit == null) return;
    
    // DEBUG: Print the selected kit details to trace the timer value
    print('=== TIMER DEBUG ===');
    print('Selected kit: ${_selectedKit!.name}');
    print('Selected kit id: ${_selectedKit!.id}');
    print('waitTimeSeconds: ${_selectedKit!.waitTimeSeconds}');
    print('All kits: ${_kits.map((k) => '${k.name}: ${k.waitTimeSeconds}s').toList()}');
    print('===================');

    HapticFeedback.mediumImpact();
    setState(() {
      _countdown = _selectedKit!.waitTimeSeconds;
      _timerActive = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _navigateToCamera();
      }
    });
  }

  void _navigateToCamera() {
    HapticFeedback.vibrate();
    Navigator.pushReplacementNamed(
      context, 
      AppRoutes.camera,
      arguments: {
        'testKit': _selectedKit?.name,
        'testKitId': _selectedKit?.id,
        'sampleId': _sampleIdController.text,
        'notes': _notesController.text,
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NarcSealColors.warmOffWhite,
      appBar: AppBar(
        title: Text(
          _timerActive ? 'TEST IN PROGRESS' : 'TEST SETUP',
        ),
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
            : (_timerActive ? _buildTimerView() : _buildKitSelection()),
      ),
    );
  }

  Widget _buildKitSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select Test Kit Type',
            style: NarcSealTypography.sectionTitle,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: NarcSealColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: NarcSealColors.lightBeige),
            ),
            child: Column(
              children: _kits.asMap().entries.map((entry) {
                final int index = entry.key;
                final TestKit kit = entry.value;
                final bool isSelected = kit.id == _selectedKit?.id;
                
                return Column(
                  children: [
                    RadioListTile<TestKit>(
                      value: kit,
                      groupValue: _selectedKit,
                      onChanged: (value) {
                        setState(() => _selectedKit = value);
                      },
                      title: Text(
                        kit.name,
                        style: NarcSealTypography.body.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      subtitle: Text(
                        'Reaction time: ${kit.waitTimeSeconds >= 60 ? '${kit.waitTimeSeconds ~/ 60}m ${kit.waitTimeSeconds % 60}s' : '${kit.waitTimeSeconds}s'}',
                        style: NarcSealTypography.metadata,
                      ),
                      activeColor: NarcSealColors.olive,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (index < _kits.length - 1)
                      const Divider(height: 1, indent: 48),
                  ],
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Additional Details (Optional)',
            style: NarcSealTypography.sectionTitle,
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _sampleIdController,
            style: NarcSealTypography.body,
            decoration: InputDecoration(
              labelText: 'Sample ID (Auto-generated)',
              labelStyle: NarcSealTypography.label,
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _notesController,
            style: NarcSealTypography.body,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add notes...',
              hintStyle: NarcSealTypography.label,
            ),
          ),
          
          const SizedBox(height: 32),
          
          ElevatedButton(
            onPressed: _selectedKit != null ? _startTimer : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('PROCEED TO TEST', style: NarcSealTypography.buttonText),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: NarcSealColors.olive, width: 8),
              ),
              child: Center(
                child: Text(
                  '${(_countdown ~/ 60).toString().padLeft(2, '0')}:${(_countdown % 60).toString().padLeft(2, '0')}',
                  style: NarcSealTypography.importantNumbers.copyWith(
                    fontSize: 48,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            
            Text(
              'Analyzing chemical reaction...',
              style: NarcSealTypography.body,
            ),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEE), // very light red
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: NarcSealColors.positive),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: NarcSealColors.positive, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'DO NOT take the photo yet.\nWait for the chemical reaction to develop.',
                      style: NarcSealTypography.body.copyWith(
                        color: NarcSealColors.positive,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NarcSealColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: NarcSealColors.lightBeige),
              ),
              child: Row(
                children: [
                  const Icon(Icons.science_outlined, color: NarcSealColors.olive, size: 24),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selected Kit', style: NarcSealTypography.metadata),
                      Text(
                        _selectedKit?.name ?? '',
                        style: NarcSealTypography.sectionTitle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
