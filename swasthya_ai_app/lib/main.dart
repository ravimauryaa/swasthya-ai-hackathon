// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Naya package
import 'features/main_layout.dart';

void main() {
  runApp(const SwasthyaApp());
}

class SwasthyaApp extends StatelessWidget {
  const SwasthyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwasthyaAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Ab app Google Fonts use karegi
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)), // Premium Teal
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC), 
      ),
      // App ab sidha MainLayout khulegi jisme bottom bar hai
      home: const MainLayout(), 
    );
  }
}