// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
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
        // Premium Google Fonts Typography
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)), 
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC), 
      ),
      // App sidha MainLayout khulegi jahan humara naya bottom bar navigation hai
      home: const MainLayout(), 
    );
  }
}