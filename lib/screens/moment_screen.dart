import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/moment.dart';
import '../services/hive_service.dart';

class MomentScreen extends StatefulWidget {
  @override
  _MomentScreenState createState() => _MomentScreenState();
}

class _MomentScreenState extends State<MomentScreen> {
  List<Moment> moments = [];

  @override
  void initState() {
    super.initState();
    loadMoments();
  }

  void loadMoments() {
    final rawData = HiveService.momentBox.values.toList();
    setState(() {
      moments = rawData.map((e) => Moment.fromMap(e as Map)).toList();
      moments.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> _addMoment() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final captionController = TextEditingController();
      
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Thêm khoảnh khắc"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(File(pickedFile.path), height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: captionController,
                  decoration: InputDecoration(
                    labelText: "Cảm nghĩ của bạn...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text("Hủy", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () {
                  final newMoment = Moment(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    imagePath: pickedFile.path,
                    caption: captionController.text,
                    date: DateTime.now(),
                  );
                  HiveService.momentBox.put(newMoment.id, newMoment.toMap());
                  Navigator.pop(context);
                  loadMoments();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Lưu", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Nhật ký thú cưng", style: TextStyle(color: Colors.teal)),
        centerTitle: true,
      ),
      body: moments.isEmpty
          ? Center(child: Text("Chưa có khoảnh khắc nào", style: TextStyle(color: Colors.grey)))
          : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: moments.length,
              itemBuilder: (context, index) {
                final moment = moments[index];
                return GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Xóa khoảnh khắc?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text("Hủy")),
                          ElevatedButton(
                            onPressed: () {
                              HiveService.momentBox.delete(moment.id);
                              Navigator.pop(context);
                              loadMoments();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: Text("Xóa", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      )
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.file(File(moment.imagePath), fit: BoxFit.cover),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  moment.caption.isNotEmpty ? moment.caption : "Một ngày tuyệt vời!",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(moment.date),
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _addMoment,
        child: Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }
}
