import 'dart:ui';
import 'package:flutter/material.dart';
import 'voice_screen.dart';
import 'main_page.dart';
import 'assets_tab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'Montserrat',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    VoiceAgentPage(),
    HomeTabView(),
    VoiceAgentScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Scaffold with Glassmorphic Bottom Bar
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _screens[_selectedIndex],
          ),
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors.black.withOpacity(0.3),
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white70,
                elevation: 0,
                showUnselectedLabels: false,
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 14,
                unselectedFontSize: 12,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.agriculture_rounded),
                    label: 'Assets',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.mic_rounded),
                    label: 'Assistant',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
