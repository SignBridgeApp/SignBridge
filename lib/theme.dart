import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signbridge/constants.dart';

ThemeData light = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    background: white,
  ),
  textTheme: GoogleFonts.openSansTextTheme(),
);

ThemeData dark = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    background: black,
  ),
  textTheme: GoogleFonts.openSansTextTheme(),
);

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = dark;
  ThemeData get themeData => _themeData;
  bool isDarkMode = true;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == light) {
      themeData = dark;
      isDarkMode = true;
    } else {
      themeData = light;
      isDarkMode = false;
    }
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return IconButton(
      color: silver,
      icon: Icon(
        themeProvider.isDarkMode
            ? Icons.light_mode_rounded
            : Icons.dark_mode_rounded,
      ),
      onPressed: () {
        themeProvider.toggleTheme();
      },
    );
  }
}
