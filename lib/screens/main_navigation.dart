import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/app_style.dart';
import 'product_screen.dart';
import 'table_screen.dart';
import 'revenue_screen.dart';

class MainNavigation extends StatelessWidget {
  final int userId;
  final String username;

  MainNavigation({required this.userId, required this.username});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: AppColors.primary,
        inactiveColor: AppColors.textSecondary,
        backgroundColor: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05), width: 0.5)),
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.square_grid_2x2_fill), label: 'Bàn'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.list_bullet), label: 'Thực đơn'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.doc_text_fill), label: 'Hóa đơn'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.chart_bar_fill), label: 'Doanh thu'),
        ],
      ),
      tabBuilder: (context, index) {
        Widget screen;
        switch (index) {
          case 0: screen = TableScreen(userId: userId); break;
          case 1: screen = ProductScreen(userId: userId); break;
          case 2: screen = RevenueScreen(userId: userId, mode: 'bills'); break;
          case 3: screen = RevenueScreen(userId: userId, mode: 'revenue'); break;
          default: screen = TableScreen(userId: userId);
        }
        return CupertinoTabView(builder: (context) => screen);
      },
    );
  }
}