import 'package:hive/hive.dart';

part 'labels.g.dart';

@HiveType(typeId: 1)
class Label {
  @HiveField(0)
  final String label;

  @HiveField(1)
  final int color;

  Label(this.label, this.color);
}