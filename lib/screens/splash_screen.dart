import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller1;
  VideoPlayerController? _controller2;
  bool _showVideo2 = false;
  bool _showFinalFrame = false;
  bool _navigated = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _controller1 = VideoPlayerController.asset('assets/videos/intro_1.mp4');
    _controller2 = VideoPlayerController.asset('assets/videos/intro_2.mp4');
    _initApp();
  }

  Future<void> _initApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    try {
      await _controller1!.initialize();
      await _controller2!.initialize();

      if (mounted) {
        setState(() {});
      }

      _controller1!.play();
      _controller1!.addListener(() {
        if (_controller1!.value.isInitialized) {
          if (_controller1!.value.position >= _controller1!.value.duration && !_showVideo2) {
            if (mounted) {
              setState(() {
                _showVideo2 = true;
              });
              _controller2!.play();
            }
          }
        }
      });

      _controller2!.addListener(() {
        if (_controller2!.value.isInitialized && _showVideo2) {
          if (_controller2!.value.position >= _controller2!.value.duration && !_showFinalFrame) {
            if (mounted) {
              setState(() {
                _showFinalFrame = true;
              });
            }
          }
        }
      });
    } catch (e) {
      print("Video error: $e");
    }

    _fallbackTimer = Timer(const Duration(seconds: 15), () {
      if (!_showFinalFrame) {
        if (mounted) {
          setState(() {
            _showVideo2 = true;
            _showFinalFrame = true;
          });
        }
      }
    });
  }

  void _navigateToNext() {
    if (_navigated) return;
    _navigated = true;
    _fallbackTimer?.cancel();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/onboarding-main');
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller1?.dispose();
    _controller2?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          Center(
            child: _showFinalFrame
                ? Image.asset(
                    'assets/images/onboarding/narcseal22.png',
                    fit: BoxFit.contain,
                  )
                : _showVideo2
                    ? (_controller2 != null && _controller2!.value.isInitialized
                        ? SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.contain, // 16:9 to 9:16 fit
                              child: SizedBox(
                                width: _controller2!.value.size.width,
                                height: _controller2!.value.size.height,
                                child: VideoPlayer(_controller2!),
                              ),
                            ),
                          )
                        : const SizedBox.shrink())
                    : (_controller1 != null && _controller1!.value.isInitialized
                        ? SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _controller1!.value.size.width,
                                height: _controller1!.value.size.height,
                                child: VideoPlayer(_controller1!),
                              ),
                            ),
                          )
                        : const SizedBox.shrink()),
          ),
          if (_showFinalFrame)
            Positioned(
              bottom: 40,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF2A2A2A),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: _navigateToNext,
              ),
            ),
        ],
      ),
    );
  }
}
