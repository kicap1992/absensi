import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeInfo {
  static const Color primary = Color(0xff0A9BAB);
  static const Color background = Color(0xffF5F5F5);
  static const Color negroTexto = Color(0xff4E4E4E);
  static const Color danger = Color.fromARGB(255, 228, 30, 30);
  static const Color myGrey = Color.fromARGB(255, 210, 212, 212);
  static const Color myGrey2 = Color.fromARGB(255, 174, 175, 175);
  static const Color readFile = Color.fromARGB(255, 22, 144, 38);

  static ThemeData getTheme() {
    return ThemeData(
      // brightness: Brightness.dark,
      // primarySwatch: generateMaterialColor(Palette.primary),
      // primaryColor: Colors.orange[400],
      // accentColor: Colors.blue,
      backgroundColor: background,
      // scaffoldBackgroundColor: const Color(0xff110e15),
      fontFamily: GoogleFonts.roboto().fontFamily,
    );
  }
}
