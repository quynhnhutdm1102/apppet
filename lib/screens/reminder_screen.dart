import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class ReminderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nhắc lịch")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔥 TEST NGAY (phải hiện 100%)
            ElevatedButton.icon(
              icon: Icon(Icons.flash_on),
              label: Text("Test NGAY"),
              onPressed: () async {
                await NotificationService.show(
                  "Test Notification",
                  "Hiện ngay lập tức",
                );
              },
            ),

            SizedBox(height: 20),

            // 🔥 TEST 10 GIÂY (không dùng 5s nữa)
            ElevatedButton.icon(
              icon: Icon(Icons.notifications),
              label: Text("Test sau 10 giây"),
              onPressed: () async {
                final scheduled = DateTime.now().add(Duration(seconds: 10));

                await NotificationService.schedule(
                  "Test Notification",
                  "Hiện sau 10 giây",
                  scheduled,
                );

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Đã đặt lịch 10s")));
              },
            ),

            SizedBox(height: 20),

            // 🔥 TEST 1 PHÚT (chắc chắn chạy)
            ElevatedButton.icon(
              icon: Icon(Icons.access_time),
              label: Text("Test sau 1 phút"),
              onPressed: () async {
                final scheduled = DateTime.now().add(Duration(minutes: 1));

                await NotificationService.schedule(
                  "Test Notification",
                  "Hiện sau 1 phút",
                  scheduled,
                );

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Đã đặt lịch 1 phút")));
              },
            ),
          ],
        ),
      ),
    );
  }
}
