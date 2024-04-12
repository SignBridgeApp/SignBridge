import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signbridge/home.dart';
import 'package:signbridge/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Sign Bridge',
            theme: themeProvider.themeData,
            home: const MyHomePage(),
          );
        },
      ),
    );
  }
}
