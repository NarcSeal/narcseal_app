import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Smart Capture',
      'desc': 'Point your camera at any drug test kit. Our AI auto-detects the card and calibrates colors.',
      'image': 'assets/images/illustrations/onboarding_scan.png',
    },
    {
      'title': 'AI Analysis',
      'desc': 'ChromaLock + ResultAI analyze colors under CIE LAB space for forensically accurate results.',
      'image': 'assets/images/illustrations/onboarding_ai.png',
    },
    {
      'title': 'Evidence Sealed',
      'desc': 'Every result is cryptographically sealed with SHA-256 hash chain. Tamper-proof by design.',
      'image': 'assets/images/illustrations/onboarding_seal.png',
    },
    {
      'title': 'Works Offline',
      'desc': 'Full functionality in areas with zero connectivity. Auto-syncs when you\'re back online.',
      'image': 'assets/images/illustrations/onboarding_offline.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A), // bgAbyss
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onSkip,
                child: Text(
                  'SKIP',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF9CA3AF), // textSecondary
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            // Parallax PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double pageOffset = 0.0;
                      if (_pageController.position.haveDimensions) {
                        pageOffset = _pageController.page! - index;
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Image with parallax effect (moves at 0.7x)
                            Transform.translate(
                              offset: Offset(pageOffset * MediaQuery.of(context).size.width * 0.7, 0),
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Image.asset(
                                  _pages[index]['image']!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 100,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),
                            
                            // Text with normal scroll speed (1.0x)
                            Transform.translate(
                              offset: Offset(pageOffset * MediaQuery.of(context).size.width, 0),
                              child: Column(
                                children: [
                                  Text(
                                    _pages[index]['title']!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.orbitron(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF06B6D4), // accentCyan
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _pages[index]['desc']!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: const Color(0xFF9CA3AF), // textSecondary
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            // Bottom section
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots indicator
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? const Color(0xFF06B6D4) // accentCyan
                              : const Color(0xFF374151), // borderSubtle
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  // Next/Get Started button
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: Text(
                      _currentIndex == _pages.length - 1 ? 'Get Started' : 'Next',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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
