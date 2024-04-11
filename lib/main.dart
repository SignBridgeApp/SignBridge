import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signbridge/home.dart';
import 'package:signbridge/theme/theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SignBridge',
            theme: themeProvider.themeData,
            home: const MyHomePage(),
            // Add the theme toggle button to the app bar
            builder: (context, child) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.blue,
                  title: Text('SignBridge'),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.light_mode_rounded,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        themeProvider.toggleTheme(); // Toggle the theme
                      },
                    ),
                  ],
                ),
                body: child,
              );
            },
          );
        },
      ),
    );
  }
}
