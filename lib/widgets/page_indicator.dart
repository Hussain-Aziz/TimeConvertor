import 'package:flutter/material.dart';
import 'dart:math' as math;

class PageIndicator extends StatelessWidget {
  PageIndicator({Key? key, required this.text, required this.flipped}) : super(key: key);
  String text;
  bool flipped;

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
