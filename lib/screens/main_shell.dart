import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../theme/app_theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'members/members_screen.dart';
import 'categories/categories_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.people_rounded, label: 'Members'),
    _NavItem(icon: Icons.category_rounded, label: 'Categories'),
  ];

  final List<Widget> _screens = const [
    DashboardScreen(),
    MembersScreen(),
    CategoriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    if (isDesktop) {
      return _DesktopLayout(
        currentIndex: _currentIndex,
        navItems: _navItems,
        screens: _screens,
        onNavTap: (i) => setState(() => _currentIndex = i),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _MobileBottomNav(
        currentIndex: _currentIndex,
        navItems: _navItems,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ─── Desktop Layout ───────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> navItems;
  final List<Widget> screens;
  final ValueChanged<int> onNavTap;

  const _DesktopLayout({
    required this.currentIndex,
    required this.navItems,
    required this.screens,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(color: Color(0x331B4332), blurRadius: 20, offset: Offset(4, 0)),
              ],
            ),
            child: Column(
              children: [
                // Logo area
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accentLight, width: 2),
                        ),
                        child: const Icon(Icons.mosque_rounded, color: AppColors.accentLight, size: 32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'مسجد مجاهد',
                        style: GoogleFonts.amiri(
                          color: AppColors.accentLight,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mujahid Masjid',
                        style: GoogleFonts.notoSans(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 12),
                // Nav items
                ...navItems.asMap().entries.map((e) {
                  final selected = e.key == currentIndex;
                  return _SidebarItem(
                    icon: e.value.icon,
                    label: e.value.label,
                    selected: selected,
                    onTap: () => onNavTap(e.key),
                  );
                }),
                const Spacer(),
                // Bottom info
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Admin', style: GoogleFonts.notoSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('Masjid Manager', style: GoogleFonts.notoSans(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(child: screens[currentIndex]),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.accentLight.withOpacity(0.4) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? AppColors.accentLight : Colors.white60,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.notoSans(
                  color: selected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (selected) ...[
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Mobile Bottom Nav ────────────────────────────────────────────
class _MobileBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> navItems;
  final ValueChanged<int> onTap;

  const _MobileBottomNav({
    required this.currentIndex,
    required this.navItems,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          children: navItems.asMap().entries.map((e) {
            final selected = e.key == currentIndex;
            return Expanded(
              child: InkWell(
                onTap: () => onTap(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: selected ? AppColors.accentLight : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(e.value.icon, color: selected ? AppColors.accentLight : Colors.white54, size: 22),
                      const SizedBox(height: 3),
                      Text(
                        e.value.label,
                        style: GoogleFonts.notoSans(
                          color: selected ? AppColors.accentLight : Colors.white54,
                          fontSize: 10,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}