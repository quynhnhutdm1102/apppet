import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const boxName = "pets";
  static const expenseBoxName = "expenses";
  static const momentBoxName = "moments";
  static const userBoxName = "users";

  // USER ĐANG ĐĂNG NHẬP
  static String? currentUser;

  static Future init() async {
    await Hive.initFlutter();

    await Hive.openBox(boxName);
    await Hive.openBox(expenseBoxName);
    await Hive.openBox(momentBoxName);
    await Hive.openBox(userBoxName);
  }

  static Box get box => Hive.box(boxName);

  static Box get expenseBox => Hive.box(expenseBoxName);

  static Box get momentBox => Hive.box(momentBoxName);

  static Box get userBox => Hive.box(userBoxName);
}
