import 'package:hive/hive.dart';

part 'archived.g.dart';

@HiveType(typeId: 2)
class Archived {
  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  String label;

  Archived(this.title, this.content, this.label);
}