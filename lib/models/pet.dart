class Pet {
  String id;
  String name;
  String type;
  int age;
  double weight;
  String image;
  String userEmail;
  List<Map<String, dynamic>> reminders;
  List<double> weightHistory;
  List<Map<String, dynamic>> vaccines;
  List<Map<String, dynamic>> dewormings;
  List<String> diseases;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.age,
    required this.weight,
    required this.image,
    required this.userEmail,
    List<Map<String, dynamic>>? reminders,
    List<double>? weightHistory,
    List<Map<String, dynamic>>? vaccines,
    List<Map<String, dynamic>>? dewormings,
    List<String>? diseases,
  }) : this.reminders = reminders ?? [],
       this.weightHistory = weightHistory ?? [weight],
       this.vaccines = vaccines ?? [],
       this.dewormings = dewormings ?? [],
       this.diseases = diseases ?? [];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "type": type,
      "age": age,
      "weight": weight,
      "image": image,
      "userEmail": userEmail,
      "reminders": reminders,
      "weightHistory": weightHistory,
      "vaccines": vaccines,
      "dewormings": dewormings,
      "diseases": diseases,
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
      userEmail: map['userEmail']?.toString() ?? '',
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
      vaccines:
          (map['vaccines'] as List?)
              ?.map((item) => Map<String, dynamic>.from(item as Map))
              .toList() ??
          [],
      dewormings:
          (map['dewormings'] as List?)
              ?.map((item) => Map<String, dynamic>.from(item as Map))
              .toList() ??
          [],
      diseases:
          (map['diseases'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
