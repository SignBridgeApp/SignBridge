import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    background: Colors.white70,
  ),
);

ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      background: Colors.black87,
    ));
