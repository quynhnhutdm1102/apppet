class Expense {
  String id;
  String title;
  double amount;
  String category;
  DateTime date;
  String? petId;

  // THÊM
  String userEmail;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.petId,
    required this.userEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "amount": amount,
      "category": category,
      "date": date.toIso8601String(),
      "petId": petId,
      "userEmail": userEmail,
    };
  }

  factory Expense.fromMap(Map map) {
    return Expense(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '0.0') ?? 0.0,
      category: map['category']?.toString() ?? 'Other',
      date: map['date'] != null
          ? DateTime.parse(map['date'].toString())
          : DateTime.now(),
      petId: map['petId']?.toString(),

      // THÊM
      userEmail: map['userEmail']?.toString() ?? '',
    );
  }
}
