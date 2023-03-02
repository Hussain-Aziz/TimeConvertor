import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubmitButton extends StatefulWidget {
  final Function() onPressed;
  final String label;
  final bool Function() isAcceptableInput;
  const SubmitButton(
      {Key? key,
      required this.label,
      required this.onPressed,
      required this.isAcceptableInput})
      : super(key: key);

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.isAcceptableInput() ? widget.onPressed : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 14, 0, 10),
          height: 55,
          width: 275,
          decoration: BoxDecoration(
            color: widget.isAcceptableInput()
                ? Colors.blue
                : const Color.fromARGB(255, 137, 195, 224),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
