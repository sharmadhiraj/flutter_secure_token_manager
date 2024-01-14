import 'package:example/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const TokenManagerDemoApp());
}

class TokenManagerDemoApp extends StatelessWidget {
  const TokenManagerDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Secure Token Manager Demo",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
