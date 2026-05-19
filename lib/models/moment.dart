class Moment {
  String id;
  String imagePath;
  String caption;
  DateTime date;
  String? petId;

  // THÊM
  String userEmail;

  Moment({
    required this.id,
    required this.imagePath,
    required this.caption,
    required this.date,
    this.petId,
    required this.userEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "imagePath": imagePath,
      "caption": caption,
      "date": date.toIso8601String(),
      "petId": petId,
      "userEmail": userEmail,
    };
  }

  factory Moment.fromMap(Map map) {
    return Moment(
      id: map['id']?.toString() ?? '',
      imagePath: map['imagePath']?.toString() ?? '',
      caption: map['caption']?.toString() ?? '',
      date: map['date'] != null
          ? DateTime.parse(map['date'].toString())
          : DateTime.now(),
      petId: map['petId']?.toString(),

      // THÊM
      userEmail: map['userEmail']?.toString() ?? '',
    );
  }
}
