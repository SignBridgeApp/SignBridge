import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signbridge/home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: GoogleFonts.openSansTextTheme(),
      ),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(),
    );
  }
}
