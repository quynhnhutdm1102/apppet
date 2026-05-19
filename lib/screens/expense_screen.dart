import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../models/pet.dart';
import '../services/hive_service.dart';

class ExpenseScreen extends StatefulWidget {
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<Expense> expenses = [];
  List<Pet> pets = [];

  final List<String> categories = [
    'Thức ăn',
    'Y tế',
    'Đồ chơi/Phụ kiện',
    'Spa/Làm đẹp',
    'Khác'
  ];

  @override
  void initState() {
    super.initState();
    loadPets();
    loadExpenses();
  }

  void loadPets() {
    final rawPets = HiveService.box.values.toList();
    setState(() {
      pets = rawPets.map((e) => Pet.fromMap(e as Map)).toList();
    });
  }

  void loadExpenses() {
    final rawData = HiveService.expenseBox.values.toList();

    setState(() {
      expenses = rawData
          .map((e) => Expense.fromMap(Map<String, dynamic>.from(e)))
          .where((e) => e.userEmail == HiveService.currentUser)
          .toList();

      expenses.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  double get currentMonthTotal {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = categories.first;
    String? selectedPetId; // null means "Dùng chung"

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text("Thêm chi tiêu"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Nội dung",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Số tiền (VNĐ)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: "Phân loại",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        setStateDialog(() => selectedCategory = val!);
                      },
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<String?>(
                      value: selectedPetId,
                      decoration: InputDecoration(
                        labelText: "Gắn với thú cưng",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text("Dùng chung (Không gắn riêng)"),
                        ),
                        ...pets.map((pet) {
                          return DropdownMenuItem<String?>(
                            value: pet.id,
                            child: Text(pet.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (val) {
                        setStateDialog(() => selectedPetId = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Hủy", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        amountController.text.isEmpty) return;

                    final newExpense = Expense(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text,
                      amount: double.tryParse(amountController.text) ?? 0,
                      category: selectedCategory,
                      date: DateTime.now(),
                    );

                    HiveService.expenseBox.put(
                      newExpense.id,
                      newExpense.toMap(),
                    );
                    Navigator.pop(context);
                    loadExpenses();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text("Lưu", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Thức ăn':
        return Icons.restaurant;
      case 'Y tế':
        return Icons.local_hospital;
      case 'Đồ chơi/Phụ kiện':
        return Icons.toys;
      case 'Spa/Làm đẹp':
        return Icons.spa;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Thức ăn':
        return Colors.orange;
      case 'Y tế':
        return Colors.redAccent;
      case 'Đồ chơi/Phụ kiện':
        return Colors.purpleAccent;
      case 'Spa/Làm đẹp':
        return Colors.pinkAccent;
      default:
        return Colors.grey;
    }
  }

  Color _getPetColor(String petName) {
    if (petName == "Dùng chung") return Colors.blueGrey;
    final int hash = petName.hashCode;
    return Colors.primaries[hash % Colors.primaries.length];
  }

  String _getPetName(String? petId) {
    if (petId == null || petId.isEmpty) return "Dùng chung";
    try {
      return pets.firstWhere((p) => p.id == petId).name;
    } catch (_) {
      return "Dùng chung";
    }
  }

  Widget _buildTotalCard() {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade300, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tổng chi tháng này",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: 5),
              Text(
                formatCurrency.format(currentMonthTotal),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(Icons.account_balance_wallet, color: Colors.white, size: 50),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data, Color Function(String) colorGetter) {
    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text("Chưa có dữ liệu", style: TextStyle(color: Colors.grey)),
      );
    }

    final double total = data.values.fold(0, (a, b) => a + b);

    List<PieChartSectionData> sections = [];
    data.forEach((key, value) {
      final percentage = (value / total * 100);
      sections.add(PieChartSectionData(
        value: value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: colorGetter(key),
        radius: 60,
        titleStyle: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    });

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 15,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: data.keys.map((key) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colorGetter(key),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5),
                Text(key, style: TextStyle(fontSize: 13)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    Map<String, double> categoryTotals = {};
    Map<String, double> petTotals = {};
    final now = DateTime.now();
    final currentMonthExpenses = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();

    for (var exp in currentMonthExpenses) {
      categoryTotals[exp.category] =
          (categoryTotals[exp.category] ?? 0) + exp.amount;
      String petName = _getPetName(exp.petId);
      petTotals[petName] = (petTotals[petName] ?? 0) + exp.amount;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTotalCard(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Chi tiêu theo danh mục",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15),
                    _buildPieChart(categoryTotals, _getCategoryColor),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Chi tiêu theo thú cưng",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15),
                    _buildPieChart(petTotals, _getPetColor),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    if (expenses.isEmpty) {
      return Center(
        child: Text("Chưa có khoản chi nào", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 10, bottom: 80),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final exp = expenses[index];
        final petName = _getPetName(exp.petId);

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(exp.category).withOpacity(0.2),
              child: Icon(
                _getCategoryIcon(exp.category),
                color: _getCategoryColor(exp.category),
              ),
            ),
            title: Text(exp.title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(exp.date)),
                if (petName != "Dùng chung")
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.pets, size: 14, color: Colors.teal),
                        SizedBox(width: 4),
                        Text(petName,
                            style: TextStyle(fontSize: 12, color: Colors.teal)),
                      ],
                    ),
                  )
              ],
            ),
            trailing: Text(
              "-${formatCurrency.format(exp.amount)}",
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            isThreeLine: petName != "Dùng chung",
            onLongPress: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Xóa khoản chi?"),
                  content: Text("Bạn có chắc muốn xóa khoản chi này?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Hủy"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        HiveService.expenseBox.delete(exp.id);
                        Navigator.pop(context);
                        loadExpenses();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text("Xóa", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text("Quản lý chi tiêu", style: TextStyle(color: Colors.teal)),
          bottom: TabBar(
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.teal,
            tabs: [
              Tab(icon: Icon(Icons.pie_chart), text: "Thống kê"),
              Tab(icon: Icon(Icons.history), text: "Lịch sử"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAnalyticsTab(),
            _buildHistoryTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          onPressed: _showAddExpenseDialog,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
