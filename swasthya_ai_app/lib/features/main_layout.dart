// lib/features/main_layout.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart'; 
import 'abha_screen.dart'; 
import 'history_screen.dart'; 
import 'consult_screen.dart'; // 👈 Nayi Consult Screen ka import

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // 👈 Ab yahan 4th Tab me asli ConsultScreen link ho chuki hai
  final List<Widget> _screens = [
    HomeScreen(), 
    const HistoryScreen(), 
    const AbhaScreen(), 
    const ConsultScreen(), // 👈 Placeholder hata diya, asli screen laga di
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), 
      
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _screens[_currentIndex],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 20, 
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // Switch tabs
            });
          },
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF0F766E),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 11),
          type: BottomNavigationBarType.fixed, 
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), 
              label: 'Triage',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded), 
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_rounded), 
              label: 'ABHA',
            ),
            // 👈 Asli Consult tab
            BottomNavigationBarItem(
              icon: Icon(Icons.support_agent_rounded), 
              label: 'Consult',
            ),
          ],
        ),
      ),
    );
  }
}