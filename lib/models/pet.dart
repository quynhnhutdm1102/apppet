class Pet {
  String id;
  String name;
  String type;
  int age;
  double weight;
  String image;
  List<Map<String, dynamic>> reminders;
  List<double> weightHistory;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.age,
    required this.weight,
    required this.image,
    List<Map<String, dynamic>>? reminders,
    List<double>? weightHistory,
  }) : this.reminders = reminders ?? [],
       this.weightHistory = weightHistory ?? [weight];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "type": type,
      "age": age,
      "weight": weight,
      "image": image,
      "reminders": reminders,
      "weightHistory": weightHistory,
    };
  }

  factory Pet.fromMap(Map map) {
    return Pet(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      age: int.tryParse(map['age']?.toString() ?? '0') ?? 0,
      weight: double.tryParse(map['weight']?.toString() ?? '0.0') ?? 0.0,
      image: map['image']?.toString() ?? '',
      // Fix lỗi chuyển đổi Map từ Hive ở đây
      reminders:
          (map['reminders'] as List?)
              ?.map((item) => Map<String, dynamic>.from(item as Map))
              .toList() ??
          [],
      weightHistory:
          (map['weightHistory'] as List?)
              ?.map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList() ??
          [],
    );
  }
}
