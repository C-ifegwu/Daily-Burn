import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'history/history_screen.dart';
import 'map/map_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  static const _screens = [
    HomeScreen(),
    HistoryScreen(),
    MapScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _idx == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, '/add-expense'),
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
        boxShadow: [
          BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Dashboard', isActive: _idx == 0, onTap: () => setState(() => _idx = 0)),
              _NavItem(icon: Icons.receipt_long_rounded, label: 'History', isActive: _idx == 1, onTap: () => setState(() => _idx = 1)),
              // Centre gap for FAB
              const SizedBox(width: 56),
              _NavItem(icon: Icons.map_rounded, label: 'Map', isActive: _idx == 2, onTap: () => setState(() => _idx = 2)),
              _NavItem(icon: Icons.person_rounded, label: 'Settings', isActive: _idx == 3, onTap: () => setState(() => _idx = 3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppTheme.primary : AppTheme.textTertiary, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppTheme.primary : AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
