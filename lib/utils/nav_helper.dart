import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/home_screen.dart';
import '../screens/chats_list_screen.dart';
import '../screens/my_ads_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/sell/sell_category_screen.dart';

/// Call this from any screen's EvBottomNavBar.onTap handler.
void handleNavTap(BuildContext context, NavTab tab, NavTab currentTab) {
  if (tab == currentTab) return;

  switch (tab) {
    case NavTab.home:
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
      break;
    case NavTab.chats:
      if (currentTab == NavTab.home) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatsListScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatsListScreen()),
        );
      }
      break;
    case NavTab.sell:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SellCategoryScreen()),
      );
      break;
    case NavTab.myAds:
      if (currentTab == NavTab.home) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyAdsScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyAdsScreen()),
        );
      }
      break;
    case NavTab.profile:
      if (currentTab == NavTab.home) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      }
      break;
  }
}
