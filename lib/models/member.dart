import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Member {
  @HiveField(0)
  String name;

  @HiveField(1)
  String role;

  Member({required this.name, required this.role});
}
