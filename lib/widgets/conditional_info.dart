import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConditionalInfo extends StatefulWidget {
  const ConditionalInfo(
      {super.key,
      required this.isVisible,
      required this.textHeader,
      required this.textDesc});

  final bool Function() isVisible;
  final String textHeader;
  final String textDesc;

  @override
  State<ConditionalInfo> createState() => _ConditionalInfoState();
}

class _ConditionalInfoState extends State<ConditionalInfo> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isVisible(),
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
              text: widget.textHeader,
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            TextSpan(
              text: widget.textDesc,
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.black),
            )
          ]),
        ),
      ),
    );
  }
}
