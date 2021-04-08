import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final bool isEditing;

  @HiveField(3)
  final String label;

  Note(this.title, this.content, this.isEditing, this.label);
}