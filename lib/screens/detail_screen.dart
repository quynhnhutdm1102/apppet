import 'package:flutter/material.dart';
import '../models/pet.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import 'health_screen.dart';

class DetailScreen extends StatefulWidget {
  final Pet pet;
  final Function(String) onDelete;
  final Function(Pet) onUpdate;

  DetailScreen({
    required this.pet,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String selectedCategory = "Ăn uống";

  final List<Map<String, dynamic>> categories = [
    {"name": "Ăn uống", "icon": Icons.restaurant, "color": Colors.orange},
    {"name": "Tiêm phòng", "icon": Icons.medical_services, "color": Colors.red},
    {"name": "Tắm rửa", "icon": Icons.waves, "color": Colors.blue},
    {"name": "Bác sĩ", "icon": Icons.local_hospital, "color": Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),

      appBar: AppBar(
        title: Text(widget.pet.name),
        foregroundColor: Colors.teal,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // IMAGE
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),

                child: Image.file(
                  File(widget.pet.image),
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: 20),

            // HEALTH
            Card(
              elevation: 2,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),

                  child: Icon(Icons.favorite, color: Colors.teal),
                ),

                title: Text(
                  "Hồ sơ sức khỏe",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Text("Cân nặng, Tiêm phòng, Tẩy giun..."),

                trailing: Icon(Icons.arrow_forward_ios, size: 16),

                onTap: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => HealthScreen(
                        pet: widget.pet,
                        onUpdate: widget.onUpdate,
                      ),
                    ),
                  ).then((_) {
                    setState(() {});
                  });
                },
              ),
            ),

            SizedBox(height: 25),

            // TITLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  "Lịch nhắc nhở",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                ElevatedButton.icon(
                  onPressed: _showAddReminderSheet,

                  icon: Icon(Icons.add, size: 18),

                  label: Text("Thêm"),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            // EMPTY
            widget.pet.reminders.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),

                      child: Text(
                        "Chưa có lịch nhắc nào",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                // LIST
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),

                    itemCount: widget.pet.reminders.length,

                    itemBuilder: (context, index) {
                      final item = widget.pet.reminders[index];

                      final cat = categories.firstWhere(
                        (c) => c['name'] == item['category'],
                        orElse: () => categories[0],
                      );

                      final bool completed = item['completed'] ?? false;

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),

                          side: BorderSide(
                            color: completed
                                ? Colors.green.shade200
                                : Colors.orange.shade200,
                          ),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(12),

                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              // ICON
                              CircleAvatar(
                                backgroundColor: cat['color'].withOpacity(0.1),

                                child: Icon(cat['icon'], color: cat['color']),
                              ),

                              SizedBox(width: 12),

                              // CONTENT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      item['category'],

                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),

                                    SizedBox(height: 5),

                                    Text(
                                      "Nhắc lúc: ${DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.parse(item['time']))}",
                                    ),

                                    SizedBox(height: 8),

                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 5,
                                      ),

                                      decoration: BoxDecoration(
                                        color: completed
                                            ? Colors.green.shade100
                                            : Colors.orange.shade100,

                                        borderRadius: BorderRadius.circular(20),
                                      ),

                                      child: Text(
                                        completed
                                            ? "Hoàn thành"
                                            : "Chưa hoàn thành",

                                        style: TextStyle(
                                          color: completed
                                              ? Colors.green
                                              : Colors.orange,

                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),

                                    // HISTORY
                                    if (completed &&
                                        item['completedTime'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),

                                        child: Text(
                                          "Đã hoàn thành lúc: ${DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.parse(item['completedTime']))}",

                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 8),

                              // ACTIONS
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        item['completed'] = !completed;

                                        if (item['completed']) {
                                          item['completedTime'] = DateTime.now()
                                              .toIso8601String();
                                        } else {
                                          item['completedTime'] = null;
                                        }
                                      });

                                      widget.onUpdate(widget.pet);
                                    },

                                    child: Icon(
                                      completed
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,

                                      color: completed
                                          ? Colors.green
                                          : Colors.grey,

                                      size: 30,
                                    ),
                                  ),

                                  SizedBox(height: 12),

                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        widget.pet.reminders.removeAt(index);
                                      });

                                      widget.onUpdate(widget.pet);
                                    },

                                    child: Icon(
                                      Icons.delete_sweep,
                                      color: Colors.redAccent,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            SizedBox(height: 30),

            Center(
              child: TextButton.icon(
                onPressed: () {
                  widget.onDelete(widget.pet.id);

                  Navigator.pop(context);
                },

                icon: Icon(Icons.delete_forever, color: Colors.red),

                label: Text(
                  "Xóa thú cưng",

                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =========================
  // ADD REMINDER
  // =========================

  void _showAddReminderSheet() {
    showModalBottomSheet(
      context: context,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Text(
                "Chọn loại hoạt động",

                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 15),

              Wrap(
                spacing: 10,

                children: categories
                    .map(
                      (c) => ChoiceChip(
                        label: Text(c['name']),

                        selected: selectedCategory == c['name'],

                        selectedColor: Colors.teal.shade100,

                        onSelected: (s) {
                          setModalState(() {
                            selectedCategory = c['name'];
                          });
                        },
                      ),
                    )
                    .toList(),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),

                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),

                onPressed: () => _pickDateTime(),

                child: Text("Chọn ngày & giờ"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // PICK DATE
  // =========================

  Future<void> _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime.now(),

      lastDate: DateTime(2030),
    );

    if (date == null) return;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final scheduled = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    await NotificationService.schedule(
      "Nhắc ${widget.pet.name}",
      "Đến giờ $selectedCategory rồi!",
      scheduled,
    );

    setState(() {
      widget.pet.reminders.add({
        "time": scheduled.toIso8601String(),
        "category": selectedCategory,
        "completed": false,
        "completedTime": null,
      });
    });

    widget.onUpdate(widget.pet);

    Navigator.pop(context);
  }
}
