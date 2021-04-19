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

  @HiveField(4)
  int color;

  Archived(this.title, this.content, this.label, this.color);
}