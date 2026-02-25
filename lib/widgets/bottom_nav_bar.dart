import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum NavTab { home, chats, sell, myAds, profile }

class EvBottomNavBar extends StatelessWidget {
  final NavTab currentTab;
  final void Function(NavTab) onTap;

  const EvBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.borderColor, width: 1),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'HOME', tab: NavTab.home, current: currentTab, onTap: onTap),
              _NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'CHATS', tab: NavTab.chats, current: currentTab, onTap: onTap),
              const SizedBox(width: 60), // space for center FAB
              _NavItem(icon: Icons.article_outlined, label: 'MY ADS', tab: NavTab.myAds, current: currentTab, onTap: onTap),
              _NavItem(icon: Icons.person_outline_rounded, label: 'PROFILE', tab: NavTab.profile, current: currentTab, onTap: onTap),
            ],
          ),

          // Center SELL button
          Positioned(
            top: -22,
            child: GestureDetector(
              onTap: () => onTap(NavTab.sell),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.black, size: 28),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'SELL',
                    style: GoogleFonts.poppins(
                      color: currentTab == NavTab.sell ? AppColors.green : AppColors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final NavTab tab;
  final NavTab current;
  final void Function(NavTab) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.tab,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = tab == current;
    return GestureDetector(
      onTap: () => onTap(tab),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? AppColors.green : AppColors.grey, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isActive ? AppColors.green : AppColors.grey,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
