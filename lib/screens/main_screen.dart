import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'expense_screen.dart';
import 'moment_screen.dart';
import 'blog_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    ExpenseScreen(),
    MomentScreen(),
    BlogScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Thú cưng'),

          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Chi tiêu',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album),
            label: 'Nhật ký',
          ),

          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Tin tức'),
        ],
      ),
    );
  }
}
