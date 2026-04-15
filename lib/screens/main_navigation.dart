import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/app_style.dart';
import 'product_screen.dart';
import 'table_screen.dart';
import 'revenue_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  final int userId;
  final String username;

  const MainNavigation({super.key, required this.userId, required this.username});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      TableScreen(userId: widget.userId),
      ProductScreen(userId: widget.userId),
      RevenueScreen(userId: widget.userId, mode: 'bills'),
      RevenueScreen(userId: widget.userId, mode: 'revenue'),
      SettingsScreen(userId: widget.userId),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.textPrimary, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.textPrimary,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.grid_view_rounded),
            _buildNavItem(1, Icons.restaurant_menu_rounded),
            _buildNavItem(2, Icons.receipt_long_rounded),
            _buildNavItem(3, Icons.bar_chart_rounded),
            _buildNavItem(4, Icons.settings_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1),
              )
            : null,
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withAlpha(150),
          size: 28,
        ),
      ),
    );
  }
}