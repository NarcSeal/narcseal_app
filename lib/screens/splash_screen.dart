import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../core/theme/colors.dart';
import '../navigation/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    
    // Animation 1: Hero Splash
    // Shield Materializing from Darkness
    // Animation 2 logic/placeholder: Transition out or morph into next sequence
    _controller = VideoPlayerController.asset('assets/videos/splash_hero.mp4')
      ..setLooping(false)
      ..setVolume(0)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.addListener(_videoListener);
      }).catchError((e) {
        // Fallback if video fails to load
        Future.delayed(const Duration(seconds: 2), _navigateToNext);
      });
  }

  void _videoListener() {
    if (_controller.value.isInitialized &&
        !_controller.value.isPlaying &&
        _controller.value.position >= _controller.value.duration) {
      _navigateToNext();
    }
  }

  void _navigateToNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _controller.removeListener(_videoListener);
    
    // Route to Login
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NarcSealColors.bgAbyss,
      body: Center(
        child: _controller.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : const CircularProgressIndicator(
                color: NarcSealColors.chromeHighlight,
              ), // Loading spinner while video initializes
      ),
    );
  }
}
