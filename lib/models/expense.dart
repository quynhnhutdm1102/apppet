class Expense {
  String id;
  String title;
  double amount;
  String category; // Food, Medical, Toy, Other
  DateTime date;
  String? petId;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.petId,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "amount": amount,
      "category": category,
      "date": date.toIso8601String(),
      "petId": petId,
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
    );
  }
}
