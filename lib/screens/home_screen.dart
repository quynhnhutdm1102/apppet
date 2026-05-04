import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/hive_service.dart';
import '../widgets/pet_card.dart';
import 'add_pet_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pet> pets = [];
  String search = "";

  @override
  void initState() {
    super.initState();
    loadPets();
  }

  void loadPets() {
    // Lấy dữ liệu thô từ Hive
    final rawData = HiveService.box.values.toList();
    setState(() {
      // Dùng Pet.fromMap(e as Map) để Hive tự xử lý kiểu dữ liệu
      pets = rawData.map((e) => Pet.fromMap(e as Map)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = pets
        .where((p) => p.name.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Thú cưng của tôi",
          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => search = v),
              decoration: InputDecoration(
                hintText: "Tìm kiếm thú cưng...",
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pets, size: 80, color: Colors.grey.shade300),
                        SizedBox(height: 10),
                        Text(
                          "Chưa có thú cưng nào",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => PetCard(
                      pet: filtered[index],
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              pet: filtered[index],
                              onDelete: (id) {
                                HiveService.box.delete(id);
                                loadPets();
                              },
                              onUpdate: (p) {
                                HiveService.box.put(p.id, p.toMap());
                                loadPets();
                              },
                            ),
                          ),
                        );
                        loadPets(); // Refresh lại danh sách sau khi quay về từ màn hình chi tiết
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        onPressed: () async {
          final pet = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddPetScreen()),
          );
          if (pet != null) {
            await HiveService.box.put(pet.id, pet.toMap());
            loadPets();
          }
        },
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Thêm Pet", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
