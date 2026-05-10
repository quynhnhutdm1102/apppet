import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../models/pet.dart';
import '../services/hive_service.dart';

class HealthScreen extends StatefulWidget {
  final Pet pet;
  final Function(Pet) onUpdate;

  const HealthScreen({Key? key, required this.pet, required this.onUpdate})
    : super(key: key);

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  late Pet _pet;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
  }

  void _savePet() {
    HiveService.box.put(_pet.id, _pet.toMap());
    widget.onUpdate(_pet);

    setState(() {});
  }

  // =========================
  // THÊM CÂN NẶNG
  // =========================

  void _addWeightRecord() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: const Text("Cập nhật cân nặng"),

        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Nhập cân nặng",
            suffixText: "kg",
            border: OutlineInputBorder(),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 244, 209, 245),
            ),
            onPressed: () {
              final value = double.tryParse(controller.text);

              if (value != null && value > 0) {
                _pet.weight = value;
                _pet.weightHistory.add(value);

                _savePet();

                Navigator.pop(context);
              }
            },
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // =========================
  // THÊM LỊCH SỬ Y TẾ
  // =========================

  void _addMedicalRecord(String type) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: Text(
          type == 'vaccine' ? "Thêm lịch tiêm phòng" : "Thêm lịch tẩy giun",
        ),

        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: type == 'vaccine' ? "Tên vaccine" : "Tên thuốc",
            border: const OutlineInputBorder(),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final record = {
                  "title": controller.text,
                  "date": DateTime.now().toIso8601String(),
                };

                if (type == 'vaccine') {
                  _pet.vaccines.add(record);
                } else {
                  _pet.dewormings.add(record);
                }

                _savePet();

                Navigator.pop(context);
              }
            },
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // =========================
  // BIỂU ĐỒ
  // =========================

  Widget _buildWeightChart() {
    if (_pet.weightHistory.isEmpty) {
      return Container(
        height: 240,
        alignment: Alignment.center,
        child: const Text("Chưa có dữ liệu cân nặng"),
      );
    }

    final spots = _pet.weightHistory.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: LineChart(
        LineChartData(
          minY: 0,

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
          ),

          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.teal.shade100),
          ),

          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

            leftTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "Kg",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 1,

                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      value.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "Lần cập nhật",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: 1,

                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "#${value.toInt() + 1}",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.teal,
              barWidth: 4,
              isStrokeCapRound: true,

              dotData: FlDotData(show: true),

              belowBarData: BarAreaData(
                show: true,
                color: Colors.teal.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // DANH SÁCH Y TẾ
  // =========================

  Widget _buildRecordList(
    String title,
    List<Map<String, dynamic>> records,
    String type,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              IconButton(
                onPressed: () => _addMedicalRecord(type),

                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.teal,
                  size: 30,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // EMPTY
          if (records.isEmpty)
            Text(
              "Chưa có dữ liệu",
              style: TextStyle(color: Colors.grey.shade600),
            ),

          // LIST
          ...records.map(
            (r) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.06),
                borderRadius: BorderRadius.circular(15),
              ),

              child: ListTile(
                contentPadding: EdgeInsets.zero,

                leading: CircleAvatar(
                  backgroundColor: Colors.teal,

                  child: Icon(
                    type == 'vaccine' ? Icons.vaccines : Icons.medication,
                    color: Colors.white,
                  ),
                ),

                title: Text(
                  r['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(r['date'])),
                ),

                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),

                  onPressed: () {
                    records.remove(r);
                    _savePet();
                  },
                ),
              ),
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
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(title: const Text("Hồ sơ sức khỏe"), centerTitle: true),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _addWeightRecord,
        child: const Icon(Icons.add),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Biểu đồ cân nặng",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              "Theo dõi sự phát triển của thú cưng",
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            _buildWeightChart(),

            const SizedBox(height: 30),

            _buildRecordList("Lịch sử Tiêm phòng", _pet.vaccines, 'vaccine'),

            _buildRecordList("Lịch sử Tẩy giun", _pet.dewormings, 'deworming'),
          ],
        ),
      ),
    );
  }
}
