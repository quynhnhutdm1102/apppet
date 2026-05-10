import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/pet.dart';
import '../services/hive_service.dart';

class HealthScreen extends StatefulWidget {
  final Pet pet;
  final Function(Pet) onUpdate;

  const HealthScreen({Key? key, required this.pet, required this.onUpdate}) : super(key: key);

  @override
  _HealthScreenState createState() => _HealthScreenState();
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

  void _addWeightRecord() {
    final weightController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cập nhật cân nặng"),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "Cân nặng (kg)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              final w = double.tryParse(weightController.text);
              if (w != null && w > 0) {
                _pet.weight = w;
                _pet.weightHistory.add(w);
                _savePet();
                Navigator.pop(context);
              }
            },
            child: Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _addMedicalRecord(String type) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == 'vaccine' ? "Thêm lịch tiêm phòng" : "Thêm lịch tẩy giun"),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: "Tên vaccine / Thuốc"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final record = {
                  "title": titleController.text,
                  "date": DateTime.now().toIso8601String()
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
            child: Text("Lưu"),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart() {
    if (_pet.weightHistory.isEmpty) return Center(child: Text("Chưa có dữ liệu cân nặng"));

    final spots = _pet.weightHistory.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.teal.shade100)),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.teal,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: Colors.teal.withOpacity(0.2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordList(String title, List<Map<String, dynamic>> records, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.add_circle, color: Colors.teal),
              onPressed: () => _addMedicalRecord(type),
            )
          ],
        ),
        if (records.isEmpty) Text("Chưa có ghi nhận nào.", style: TextStyle(color: Colors.grey)),
        ...records.map((r) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(type == 'vaccine' ? Icons.vaccines : Icons.medication, color: Colors.teal),
          title: Text(r['title'] ?? ''),
          subtitle: Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(r['date']))),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              records.remove(r);
              _savePet();
            },
          ),
        )).toList(),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hồ sơ sức khỏe"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Biểu đồ cân nặng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _addWeightRecord,
                  icon: Icon(Icons.monitor_weight),
                  label: Text("Cập nhật"),
                )
              ],
            ),
            SizedBox(height: 10),
            _buildWeightChart(),
            SizedBox(height: 30),
            _buildRecordList("Lịch sử Tiêm phòng", _pet.vaccines, 'vaccine'),
            SizedBox(height: 10),
            _buildRecordList("Lịch sử Tẩy giun", _pet.dewormings, 'deworming'),
          ],
        ),
      ),
    );
  }
}
