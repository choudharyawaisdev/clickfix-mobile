import 'package:flutter/material.dart';
import 'package:clickfix/screens/splash_screen.dart';
import 'package:clickfix/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClickFix',
      debugShowCheckedModeBanner: false,
      theme: ClickFixTheme.lightTheme,
      darkTheme: ClickFixTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
