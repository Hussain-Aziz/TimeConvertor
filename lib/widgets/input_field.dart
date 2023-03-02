// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class InputField extends StatelessWidget {
  final controller;
  final String prompt;
  final Icon prefixIcon;
  final Function()? onChanged;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? textInputFormatters;

  const InputField(
      {Key? key,
      required this.controller,
      required this.prompt,
      required this.prefixIcon,
      this.onChanged,
      this.textInputType, 
      this.textInputFormatters})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        keyboardType: textInputType ?? TextInputType.name,
        inputFormatters: textInputFormatters,
        cursorColor: const Color(0xFF4f4f4f),
        decoration: InputDecoration(
          hintText: prompt,
          fillColor: const Color.fromARGB(255, 236, 250, 254),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          hintStyle: GoogleFonts.poppins(
            fontSize: 15,
            color: const Color(0xFF8d8d8d),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: prefixIcon,
          prefixIconColor: const Color(0xFF4f4f4f),
          filled: true,
        ),
      ),
    );
  }
}
