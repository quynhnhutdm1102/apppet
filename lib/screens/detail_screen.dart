import 'package:flutter/material.dart';
import '../models/pet.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/notification_service.dart';

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

  // --- HÀM MỚI: HIỂN THỊ CỬA SỔ NHẬP CÂN NẶNG ---
  void _showUpdateWeightDialog() {
    final weightController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cập nhật cân nặng"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText: "kg",
            hintText: "Nhập cân nặng mới",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              if (weightController.text.isNotEmpty) {
                double? newWeight = double.tryParse(weightController.text);
                if (newWeight != null) {
                  setState(() {
                    widget.pet.weight = newWeight;
                    widget.pet.weightHistory.add(newWeight);
                  });
                  widget.onUpdate(widget.pet); // Lưu vào Hive
                }
                Navigator.pop(context);
              }
            },
            child: Text("Cập nhật", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
            // 1. Ảnh và Thông tin cơ bản
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

            // 2. Biểu đồ cân nặng + NÚT CẬP NHẬT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Theo dõi cân nặng (kg)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // NÚT BẤM CẬP NHẬT Ở ĐÂY
                IconButton(
                  icon: Icon(Icons.add_chart, color: Colors.teal, size: 28),
                  onPressed: _showUpdateWeightDialog,
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              height: 180,
              padding: EdgeInsets.only(right: 20, top: 15, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: widget.pet.weightHistory
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: Colors.teal,
                      barWidth: 4,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.teal.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 25),

            // 3. Phần đặt lịch nhắc phân loại
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

            // Danh sách lịch nhắc
            widget.pet.reminders.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Chưa có lịch nhắc nào",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
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
                      return Card(
                        margin: EdgeInsets.only(bottom: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: cat['color'].withOpacity(0.1),
                            child: Icon(cat['icon'], color: cat['color']),
                          ),
                          title: Text(
                            item['category'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            DateFormat(
                              'dd/MM - HH:mm',
                            ).format(DateTime.parse(item['time'])),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_sweep,
                              color: Colors.redAccent.withOpacity(0.7),
                            ),
                            onPressed: () {
                              setState(
                                () => widget.pet.reminders.removeAt(index),
                              );
                              widget.onUpdate(widget.pet);
                            },
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

  // --- GIỮ NGUYÊN CÁC HÀM CŨ ---
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
                        onSelected: (s) =>
                            setModalState(() => selectedCategory = c['name']),
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
      });
    });

    widget.onUpdate(widget.pet);
    Navigator.pop(context);
  }
}
