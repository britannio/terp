import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:terp/home_page.dart';

class TerpApp extends StatelessWidget {
  const TerpApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TERP',
      theme: FlexColorScheme.light(
        scheme: FlexScheme.hippieBlue,
      ).toTheme.copyWith(textTheme: GoogleFonts.balsamiqSansTextTheme()),
      home: const HomePage(),
    );
  }
}
