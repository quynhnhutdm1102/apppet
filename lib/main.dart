import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'screens/welcome_screen.dart';

// Hàm xin quyền thông báo và báo thức chính xác
Future<void> requestPermissions() async {
  // Xin quyền hiện thông báo (Dành cho Android 13+)
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // Xin quyền báo thức chính xác (Bắt buộc cho Android 12+ để đặt lịch nhắc)
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}

void main() async {
  // Đảm bảo Flutter framework được khởi tạo trước khi gọi các plugin
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo các dịch vụ nền
  await HiveService.init(); // Khởi tạo cơ sở dữ liệu Hive
  await NotificationService.init(); // Khởi tạo dịch vụ thông báo
  await requestPermissions(); // Xin các quyền cần thiết

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Pet Manager Pro",

      // Thiết lập Theme chung cho toàn App theo phong cách hiện đại
      theme: ThemeData(
        useMaterial3:
            true, // Sử dụng Material 3 để giao diện đồng bộ, bo góc đẹp hơn
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal,
          secondary: Colors.orangeAccent,
        ),
        // Cấu hình AppBar mặc định cho toàn app
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        // Cấu hình font chữ mặc định
        fontFamily: 'Roboto',
      ),

      // Trang chủ đầu tiên là WelcomeScreen theo yêu cầu của bạn
      home: WelcomeScreen(),
    );
  }
}
