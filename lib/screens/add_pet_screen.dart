import 'package:flutter/material.dart';
import '../models/pet.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddPetScreen extends StatefulWidget {
  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final name = TextEditingController();
  final type = TextEditingController();
  final age = TextEditingController();
  final weight = TextEditingController();

  File? image;

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  void save() {
    if (image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vui lòng chọn ảnh")));
      return;
    }

    final pet = Pet(
      id: Random().nextDouble().toString(),
      name: name.text,
      type: type.text,
      age: int.parse(age.text),
      weight: double.parse(weight.text),
      image: image!.path,
    );

    Navigator.pop(context, pet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thêm thú cưng")),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: image != null ? FileImage(image!) : null,
                child: image == null ? Icon(Icons.camera_alt, size: 30) : null,
              ),
            ),
            SizedBox(height: 20),

            buildInput(name, "Tên"),
            buildInput(type, "Loài"),
            buildInput(age, "Tuổi", isNumber: true),
            buildInput(weight, "Cân nặng", isNumber: true),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: save,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text("Lưu", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInput(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
