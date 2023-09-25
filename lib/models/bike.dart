import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Bike {
  @HiveField(0)
  String model;

  @HiveField(1)
  String make;

  Bike({required this.model, required this.make});
}
