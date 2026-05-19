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

  const DetailScreen({
    super.key,
    required this.pet,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
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
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        title: Text(widget.pet.name),
        foregroundColor: Colors.teal,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =========================
            // IMAGE
            // =========================
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

            const SizedBox(height: 20),

            // =========================
            // HEALTH CARD
            // =========================
            Card(
              elevation: 3,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),

                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(Icons.favorite, color: Colors.teal),
                    ),

                    title: const Text(
                      "Hồ sơ sức khỏe",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: const Text("Cân nặng, Tiêm phòng, Tẩy giun..."),

                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),

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

                  // =========================
                  // GIẢI THÍCH BIỂU ĐỒ
                  // =========================
                  Container(
                    width: double.infinity,

                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),

                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.info_outline,
                              color: Colors.teal,
                              size: 18,
                            ),

                            SizedBox(width: 6),

                            Text(
                              "Biểu đồ sức khỏe",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        _buildGuideItem(
                          color: Colors.blue,
                          text: "Đường màu xanh: Cân nặng theo thời gian",
                        ),

                        const SizedBox(height: 6),

                        _buildGuideItem(
                          color: Colors.orange,
                          text: "Điểm càng cao → cân nặng càng lớn",
                        ),

                        const SizedBox(height: 6),

                        _buildGuideItem(
                          color: Colors.green,
                          text:
                              "Theo dõi tăng/giảm cân để biết thú cưng có khỏe mạnh không",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // TITLE
            // =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  "Lịch nhắc nhở",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                ElevatedButton.icon(
                  onPressed: _showAddReminderSheet,

                  icon: const Icon(Icons.add, size: 18),

                  label: const Text("Thêm"),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // =========================
            // EMPTY
            // =========================
            widget.pet.reminders.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),

                      child: Text(
                        "Chưa có lịch nhắc nào",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                // =========================
                // LIST
                // =========================
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),

                    itemCount: widget.pet.reminders.length,

                    itemBuilder: (context, index) {
                      final item = widget.pet.reminders[index];

                      final cat = categories.firstWhere(
                        (c) => c['name'] == item['category'],
                        orElse: () => categories[0],
                      );

                      final bool completed = item['completed'] ?? false;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),

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

                              const SizedBox(width: 12),

                              // CONTENT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      item['category'],

                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      "Nhắc lúc: ${DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.parse(item['time']))}",
                                    ),

                                    const SizedBox(height: 8),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
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

                              const SizedBox(width: 8),

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

                                  const SizedBox(height: 12),

                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        widget.pet.reminders.removeAt(index);
                                      });

                                      widget.onUpdate(widget.pet);
                                    },

                                    child: const Icon(
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

            const SizedBox(height: 30),

            // =========================
            // DELETE PET
            // =========================
            Center(
              child: TextButton.icon(
                onPressed: () {
                  widget.onDelete(widget.pet.id);

                  Navigator.pop(context);
                },

                icon: const Icon(Icons.delete_forever, color: Colors.red),

                label: const Text(
                  "Xóa thú cưng",

                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =========================
  // GUIDE ITEM
  // =========================

  Widget _buildGuideItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,

          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: 8),

        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  // =========================
  // ADD REMINDER
  // =========================

  void _showAddReminderSheet() {
    showModalBottomSheet(
      context: context,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Text(
                "Chọn loại hoạt động",

                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

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

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),

                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),

                onPressed: () => _pickDateTime(),

                child: const Text("Chọn ngày & giờ"),
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
