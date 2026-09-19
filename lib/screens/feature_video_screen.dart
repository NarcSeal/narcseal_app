import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureVideoScreen extends StatefulWidget {
  final String title;
  final String videoPath;

  const FeatureVideoScreen({
    Key? key,
    required this.title,
    required this.videoPath,
  }) : super(key: key);

  @override
  State<FeatureVideoScreen> createState() => _FeatureVideoScreenState();
}

class _FeatureVideoScreenState extends State<FeatureVideoScreen> {
  late VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(false);
        _controller.setVolume(1.0);
        _controller.play();
      }).catchError((error) {
        setState(() {
          _hasError = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video Layer
          if (_hasError)
            const Center(
              child: Text(
                'Video failed to load.',
                style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 16),
              ),
            )
          else if (_controller.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFE0E0E0)),
            ),

          // Title Overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: const Color(0xFF000000).withOpacity(0.7),
              padding: EdgeInsets.only(
                top: 24.0,
                bottom: 24.0 + MediaQuery.of(context).padding.bottom,
                left: 16.0,
                right: 16.0,
              ),
              alignment: Alignment.center,
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE0E0E0),
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A).withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
