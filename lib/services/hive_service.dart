import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const boxName = "pets";

  static Future init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static Box get box => Hive.box(boxName);
}
