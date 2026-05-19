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

  final Color primaryColor = Colors.teal;

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

  // =====================================================
  // THÊM CÂN NẶNG
  // =====================================================

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
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),

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

  // =====================================================
  // THÊM HỒ SƠ Y TẾ
  // =====================================================

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
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),

            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final record = {
                  "title": controller.text.trim(),
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

  // =====================================================
  // XÓA RECORD
  // =====================================================

  void _confirmDelete({
    required List<Map<String, dynamic>> records,
    required Map<String, dynamic> item,
    required String title,
  }) {
    showDialog(
      context: context,

      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: const Text("Xóa dữ liệu"),

        content: Text("Bạn có chắc muốn xóa \"$title\" không?"),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

            onPressed: () {
              records.remove(item);

              _savePet();

              Navigator.pop(context);
            },

            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // GIẢI THÍCH BIỂU ĐỒ
  // =====================================================

  Widget _buildChartGuide() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: primaryColor),

              const SizedBox(width: 8),

              const Text(
                "Giải thích biểu đồ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _guideItem("Trục ngang (#1, #2...)", "Là số lần cập nhật cân nặng"),

          const SizedBox(height: 8),

          _guideItem("Trục dọc", "Là cân nặng của thú cưng (kg)"),

          const SizedBox(height: 8),

          _guideItem("Đường biểu đồ tăng", "Thú cưng đang phát triển tốt"),

          const SizedBox(height: 8),

          _guideItem("Đường biểu đồ giảm", "Có thể thú cưng đang sụt cân"),
        ],
      ),
    );
  }

  Widget _guideItem(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Icon(Icons.circle, size: 8, color: primaryColor),

        const SizedBox(width: 8),

        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey.shade800, fontSize: 13),

              children: [
                TextSpan(
                  text: "$title: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // BIỂU ĐỒ
  // =====================================================

  Widget _buildWeightChart() {
    if (_pet.weightHistory.isEmpty) {
      return Container(
        height: 250,

        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),

        child: const Text("Chưa có dữ liệu cân nặng"),
      );
    }

    final spots = _pet.weightHistory.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return Container(
      height: 320,

      padding: const EdgeInsets.fromLTRB(10, 25, 25, 20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(25),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: LineChart(
        LineChartData(
          minY: 0,

          clipData: FlClipData.none(),

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
          ),

          borderData: FlBorderData(
            show: true,

            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),

          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

            // Y
            leftTitles: AxisTitles(
              axisNameWidget: Padding(
                padding: const EdgeInsets.only(bottom: 10),

                child: Text(
                  "KG",

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),

              axisNameSize: 25,

              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 1,

                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),

                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  );
                },
              ),
            ),

            // X
            bottomTitles: AxisTitles(
              axisNameWidget: Padding(
                padding: const EdgeInsets.only(top: 12),

                child: Text(
                  "Số lần cập nhật",

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),

              axisNameSize: 35,

              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,

                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),

                    child: Text(
                      "#${value.toInt() + 1}",

                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
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

              color: primaryColor,

              barWidth: 4,

              isStrokeCapRound: true,

              dotData: FlDotData(show: true),

              belowBarData: BarAreaData(
                show: true,

                color: primaryColor.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // CARD RECORD VIP
  // =====================================================

  Widget _buildMedicalCard({
    required Map<String, dynamic> item,
    required String type,
    required List<Map<String, dynamic>> records,
  }) {
    final date = DateFormat('dd/MM/yyyy').format(DateTime.parse(item['date']));

    final bool isVaccine = type == 'vaccine';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.12), Colors.white],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: primaryColor.withOpacity(0.15)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: isVaccine ? Colors.teal : Colors.orange,

              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(
              isVaccine ? Icons.vaccines : Icons.medication,

              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  item['title'],

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      date,

                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: isVaccine
                        ? Colors.teal.withOpacity(0.12)
                        : Colors.orange.withOpacity(0.12),

                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Text(
                    isVaccine ? "Đã tiêm phòng" : "Đã tẩy giun",

                    style: TextStyle(
                      color: isVaccine ? Colors.teal : Colors.orange,

                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),

            onPressed: () {
              _confirmDelete(
                records: records,
                item: item,
                title: item['title'],
              );
            },
          ),
        ],
      ),
    );
  }

  // =====================================================
  // DANH SÁCH
  // =====================================================

  Widget _buildRecordList(
    String title,
    List<Map<String, dynamic>> records,
    String type,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(25),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
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

                icon: Icon(Icons.add_circle, color: primaryColor, size: 30),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),

              child: Center(
                child: Text(
                  "Chưa có dữ liệu",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),

          ...records.map(
            (r) => _buildMedicalCard(item: r, type: type, records: records),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Hồ sơ sức khỏe"),

        centerTitle: true,

        foregroundColor: Colors.teal,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,

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

            _buildChartGuide(),

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
