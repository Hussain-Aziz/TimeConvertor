import 'package:flutter/material.dart';
import 'dart:math' as math;

class OtherPageIndicator extends StatelessWidget {
  const OtherPageIndicator({Key? key, required this.text, required this.flipped}) : super(key: key);
  final String text;
  final bool flipped;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform.rotate(angle: flipped ? math.pi: 0, child: Icon(Icons.arrow_back, color: Colors.grey.shade400)),
        Text(text, style: TextStyle(fontSize: 18, color: Colors.grey.shade400)),
      ],
    );
  }
}
