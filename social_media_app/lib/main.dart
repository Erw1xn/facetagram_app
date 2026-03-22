import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MetaFlowApp());
}

class MetaFlowApp extends StatelessWidget {
  const MetaFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Facetagram',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
      ),
      home: const HomeScreen(),
    );
  }
}