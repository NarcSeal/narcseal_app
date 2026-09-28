import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../navigation/app_router.dart';
import '../services/api_service.dart';
import '../models/evidence_record.dart';
import '../models/test_result.dart';

class EvidenceSealScreen extends StatefulWidget {
  const EvidenceSealScreen({super.key});

  @override
  State<EvidenceSealScreen> createState() => _EvidenceSealScreenState();
}

class _EvidenceSealScreenState extends State<EvidenceSealScreen> {
  final TextEditingController _sealIdController = TextEditingController();
  String _resultType = 'POSITIVE';
  bool _isSyncing = false;
  final String _recordId = const Uuid().v4();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['result'] != null) {
      _resultType = args['result'] as String;
    }
  }

  @override
  void dispose() {
    _sealIdController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndSeal() async {
    HapticFeedback.heavyImpact();
    setState(() => _isSyncing = true);
    
    final officer = ApiService.currentOfficer;
    final record = EvidenceRecord(
      recordId: _recordId,
      officerBadgeId: officer.badgeId,
      officerName: officer.fullName,
      timestamp: DateTime.now(),
      latitude: 28.6139, 
      longitude: 77.2090, 
      address: 'Connaught Place, New Delhi',
      testResult: _resultType == 'POSITIVE' ? TestResult.positive : (_resultType == 'NEGATIVE' ? TestResult.negative : TestResult.inconclusive),
      substance: _resultType == 'POSITIVE' ? 'Cocaine Hydrochloride' : (_resultType == 'NEGATIVE' ? 'No Narcotics Detected' : 'Unknown Substance'),
      confidence: 0.998,
      imageHash: '8f4b0292193b092a101b0f92223a9109',
      previousHash: '2c99a0928bb019f2a991b11b',
      recordHash: '8F4C299A0928BB019F2A991B11B',
      deviceId: 'DEVICE-1029',
      isSynced: false,
      isSealed: true,
      createdAt: DateTime.now(),
    );

    final success = await ApiService.uploadTestRecord(record);
    
    if (mounted) {
      setState(() => _isSyncing = false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evidence Sealed and Synced Successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evidence Sealed locally. Sync failed.')),
        );
      }
      
      // Route back to home
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NarcSealColors.warmOffWhite,
      appBar: AppBar(
        title: const Text('EVIDENCE SEALING'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NarcSealColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NarcSealColors.lightBeige),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sample ID', style: NarcSealTypography.metadata),
                    Text('NS-2026-004282', style: NarcSealTypography.body.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    
                    Text('GPS Location', style: NarcSealTypography.metadata),
                    Text('28.6139° N, 77.2090° E', style: NarcSealTypography.body.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    
                    Text('Hash', style: NarcSealTypography.metadata),
                    Text(
                      '8F4C299A0928BB019F2A991B11B', 
                      style: NarcSealTypography.metadata.copyWith(
                        color: NarcSealColors.graphite,
                        fontWeight: FontWeight.w500,
                      )
                    ),
                    const SizedBox(height: 24),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1), // Light Amber
                        border: Border.all(color: Colors.amber),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            'Digital Signature Pending',
                            style: NarcSealTypography.label.copyWith(
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'Scan the NFC Evidence Bag or enter Seal ID manually.',
                style: NarcSealTypography.body,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isSyncing ? null : () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.nfc, size: 20),
                    const SizedBox(width: 12),
                    Text('SCAN NFC SEAL', style: NarcSealTypography.buttonText),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('OR', style: NarcSealTypography.label),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              
              const SizedBox(height: 32),
              
              TextField(
                controller: _sealIdController,
                style: NarcSealTypography.body,
                decoration: InputDecoration(
                  labelText: 'Manual Seal ID',
                  labelStyle: NarcSealTypography.label,
                  hintText: 'e.g. BAG-88392',
                ),
              ),
              
              const SizedBox(height: 24),
              
              OutlinedButton(
                onPressed: _isSyncing ? null : _verifyAndSeal,
                child: _isSyncing 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: NarcSealColors.olive, strokeWidth: 2)
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_outlined, size: 20),
                        const SizedBox(width: 12),
                        Text('VERIFY & SEAL', style: NarcSealTypography.buttonText.copyWith(color: NarcSealColors.titaniumGray)),
                      ],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
