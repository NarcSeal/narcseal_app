import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

class HashText extends StatefulWidget {
  final String hash;
  final int maxLength;
  final TextStyle? style;

  const HashText({
    super.key,
    required this.hash,
    this.maxLength = 12,
    this.style,
  });

  @override
  State<HashText> createState() => _HashTextState();
}

class _HashTextState extends State<HashText> {
  bool _isExpanded = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.hash));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayHash = _isExpanded || widget.hash.length <= widget.maxLength
        ? widget.hash
        : '${widget.hash.substring(0, widget.maxLength)}...';

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      onDoubleTap: _copyToClipboard,
      child: Text(
        displayHash,
        style: widget.style ??
            const TextStyle(
              fontFamily: 'JetBrains Mono', // Monospace font
              color: NarcSealColors.accentCyan,
              fontSize: 14,
            ),
      ),
    );
  }
}
