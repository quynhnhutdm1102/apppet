import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'expense_screen.dart';
import 'moment_screen.dart';
import 'map_screen.dart';
import 'login_screen.dart';
import '../services/hive_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    ExpenseScreen(),
    MomentScreen(),
    MapScreen(),
  ];

  // =========================
  // ĐĂNG XUẤT
  // =========================

  void logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc muốn đăng xuất không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

            onPressed: () {
              // XÓA USER HIỆN TẠI
              HiveService.currentUser = "";

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },

            child: const Text(
              "Đăng xuất",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PET MANAGER"),

        backgroundColor: Colors.teal,

        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),

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

          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Bản đồ'),
        ],
      ),
    );
  }
}
