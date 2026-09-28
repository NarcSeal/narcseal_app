import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../navigation/app_router.dart';
import '../core/theme/colors.dart';

class IntroVideosScreen extends StatefulWidget {
  const IntroVideosScreen({super.key});

  @override
  State<IntroVideosScreen> createState() => _IntroVideosScreenState();
}

class _IntroVideosScreenState extends State<IntroVideosScreen> {
  VideoPlayerController? _controller;
  int _currentVideoIndex = 0;
  final List<String> _videos = [
    'assets/videos/video_for_scroll_2.mp4',
    'assets/videos/video_for_scroll_3.mp4',
  ];
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _playNextVideo();
  }

  Future<void> _playNextVideo() async {
    if (_currentVideoIndex >= _videos.length) {
      if (!_isTransitioning) {
        _isTransitioning = true;
        Navigator.of(context).pushReplacementNamed(AppRoutes.mainSplash);
      }
      return;
    }

    final oldController = _controller;
    _controller = VideoPlayerController.asset(_videos[_currentVideoIndex]);
    
    _controller!.addListener(_videoListener);
    
    await _controller!.initialize();
    
    oldController?.removeListener(_videoListener);
    oldController?.dispose();

    setState(() {});
    
    _controller!.play();
  }

  void _videoListener() {
    if (_controller != null && _controller!.value.isInitialized) {
      if (_controller!.value.position >= _controller!.value.duration && !_isTransitioning) {
        _controller!.removeListener(_videoListener);
        _currentVideoIndex++;
        _playNextVideo();
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller != null && _controller!.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
