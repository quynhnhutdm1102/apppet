import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/moment.dart';
import '../services/hive_service.dart';

class MomentScreen extends StatefulWidget {
  const MomentScreen({super.key});

  @override
  State<MomentScreen> createState() => _MomentScreenState();
}

class _MomentScreenState extends State<MomentScreen> {
  List<Moment> moments = [];

  @override
  void initState() {
    super.initState();
    loadMoments();
  }

  // =========================
  // LOAD DATA
  // =========================

  void loadMoments() {
    final rawData = HiveService.momentBox.values.toList();

    setState(() {
      moments = rawData
          .map((e) => Moment.fromMap(Map<String, dynamic>.from(e)))
          .where((e) => e.userEmail == HiveService.currentUser)
          .toList();

      moments.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  // =========================
  // THÊM KHOẢNH KHẮC
  // =========================

  Future<void> _addMoment() async {
    try {
      final picker = ImagePicker();

      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      final captionController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            title: const Text("Thêm khoảnh khắc"),

            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),

                    child: Image.file(
                      File(pickedFile.path),
                      height: 170,
                      width: 250,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: captionController,
                    maxLines: 3,

                    decoration: InputDecoration(
                      labelText: "Cảm nghĩ của bạn...",

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),

                child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                onPressed: () async {
                  final newMoment = Moment(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    imagePath: pickedFile.path,
                    caption: captionController.text.trim(),
                    date: DateTime.now(),
                    userEmail: HiveService.currentUser ?? "",
                  );

                  await HiveService.momentBox.put(
                    newMoment.id,
                    newMoment.toMap(),
                  );

                  Navigator.pop(context);

                  loadMoments();
                },

                child: const Text("Lưu", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  // =========================
  // XEM CHI TIẾT KHOẢNH KHẮC
  // =========================

  void _showFullImage(Moment moment) {
    showDialog(
      context: context,

      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),

          clipBehavior: Clip.antiAlias,

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // IMAGE
                Stack(
                  children: [
                    InteractiveViewer(
                      child: Image.file(
                        File(moment.imagePath),
                        width: double.infinity,
                        height: 320,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Positioned(
                      top: 10,
                      right: 10,

                      child: CircleAvatar(
                        backgroundColor: Colors.black54,

                        child: IconButton(
                          onPressed: () => Navigator.pop(context),

                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                // CONTENT
                Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "Nội dung",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        moment.caption.isNotEmpty
                            ? moment.caption
                            : "Không có nội dung",

                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            DateFormat(
                              'dd/MM/yyyy - HH:mm',
                            ).format(moment.date),

                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // HỘP THOẠI XÓA
  // =========================

  Future<bool> _confirmDelete(Moment moment) async {
    final result = await showDialog<bool>(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text("Xóa khoảnh khắc?"),

        content: const Text("Bạn có chắc muốn xóa ảnh này không?"),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),

            child: const Text("Hủy"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

            onPressed: () async {
              await HiveService.momentBox.delete(moment.id);

              Navigator.pop(context, true);
            },

            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(title: const Text("Nhật ký thú cưng"), centerTitle: true),

      body: moments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.photo_album,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Chưa có khoảnh khắc nào",

                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),

              itemCount: moments.length,

              itemBuilder: (context, index) {
                final moment = moments[index];

                final file = File(moment.imagePath);

                return Dismissible(
                  key: Key(moment.id),

                  direction: DismissDirection.endToStart,

                  background: Container(
                    alignment: Alignment.centerRight,

                    padding: const EdgeInsets.only(right: 20),

                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  confirmDismiss: (_) async {
                    final confirm = await _confirmDelete(moment);

                    if (confirm) {
                      loadMoments();
                    }

                    return confirm;
                  },

                  child: GestureDetector(
                    onTap: () => _showFullImage(moment),

                    onLongPress: () async {
                      final confirm = await _confirmDelete(moment);

                      if (confirm) {
                        loadMoments();
                      }
                    },

                    child: Card(
                      elevation: 4,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),

                      clipBehavior: Clip.antiAlias,

                      child: Stack(
                        children: [
                          // IMAGE
                          Positioned.fill(
                            child: file.existsSync()
                                ? Image.file(file, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey.shade300,

                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                          ),

                          // GRADIENT
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,

                            child: Container(
                              padding: const EdgeInsets.all(10),

                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,

                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Text(
                                    moment.caption.isNotEmpty
                                        ? moment.caption
                                        : "Một ngày tuyệt vời!",

                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,

                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy - HH:mm',
                                    ).format(moment.date),

                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(2, 137, 114, 1),

        onPressed: _addMoment,

        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }
}
