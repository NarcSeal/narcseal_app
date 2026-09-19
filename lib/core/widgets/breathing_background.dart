import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// A reusable widget that loops a background video, used for the
/// "Breathing" and "Ambient" animations described in the Animation Guide.
class BreathingBackground extends StatefulWidget {
  final String videoAssetPath;
  final Widget child;
  final double opacity;
  final BoxFit fit;

  const BreathingBackground({
    super.key,
    required this.videoAssetPath,
    required this.child,
    this.opacity = 1.0,
    this.fit = BoxFit.cover,
  });

  @override
  State<BreathingBackground> createState() => _BreathingBackgroundState();
}

class _BreathingBackgroundState extends State<BreathingBackground> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(widget.videoAssetPath);
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(0.0); // Backgrounds should be silent
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
      }
    } catch (e) {
      // Fallback if the video asset doesn't exist yet
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Pure black base
        Container(color: Colors.black),
        
        // Video Layer
        if (_isInitialized && !_hasError)
          Opacity(
            opacity: widget.opacity,
            child: FittedBox(
              fit: widget.fit,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          
        // Optional fallback: subtle gradient if video missing
        if (_hasError)
          Opacity(
            opacity: 0.1 * widget.opacity,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.5,
                  colors: [Colors.white, Colors.black],
                ),
              ),
            ),
          ),

        // Foreground content
        widget.child,
      ],
    );
  }
}
