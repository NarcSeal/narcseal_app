import 'dart:async';
import 'package:flutter/material.dart';

class TypingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration delay;
  final bool showCursor;
  final bool glowEffect;
  final VoidCallback? onComplete;

  const TypingText({
    super.key,
    required this.text,
    this.style = const TextStyle(),
    this.delay = const Duration(milliseconds: 50),
    this.showCursor = true,
    this.glowEffect = false,
    this.onComplete,
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  String _displayedText = "";
  int _currentIndex = 0;
  Timer? _typingTimer;
  Timer? _cursorTimer;
  bool _cursorVisible = true;

  @override
  void initState() {
    super.initState();
    _startTyping();
    if (widget.showCursor) {
      _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (mounted) setState(() => _cursorVisible = !_cursorVisible);
      });
    }
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(widget.delay, (timer) {
      if (_currentIndex < widget.text.length) {
        if (mounted) {
          setState(() {
            _displayedText += widget.text[_currentIndex];
            _currentIndex++;
          });
        }
      } else {
        timer.cancel();
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      }
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: widget.style,
        children: [
          TextSpan(
            text: _displayedText,
            style: widget.glowEffect
                ? widget.style.copyWith(
                    shadows: [
                      Shadow(
                        color: Colors.green.withOpacity(0.8),
                        blurRadius: 4,
                      )
                    ],
                  )
                : widget.style,
          ),
          if (widget.showCursor)
            TextSpan(
              text: '_',
              style: widget.style.copyWith(
                color: _cursorVisible ? widget.style.color : Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }
}
