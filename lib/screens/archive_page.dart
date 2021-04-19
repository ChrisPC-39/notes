import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../database/note.dart';
import '../database/archived.dart';
import '../style/decoration.dart' as style;

class ArchivePage extends StatefulWidget {
  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  void deleteAll() async {
    Hive.box("archive").clear();
  }

  void restoreAll() {
    final archiveBox = Hive.box("archive");

    for(int i = 0; i < archiveBox.length; i++) {
      final note = archiveBox.getAt(i) as Archived;

      Hive.box("note").add(Note(note.title, note.content, false, note.label, note.color));
      setState(() => archiveBox.deleteAt(i));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF424242),
        body: Column(
          children: [
            _buildTopBar(),
            Divider(thickness: 1, color: Colors.white),
            _buildListView()
          ]
        )
      )
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(5, 20, 5, 0),
      child: Row(
        children: [
          _buildBackButton(),
          SizedBox(width: 15),
          _buildTitle(),
          _buildOptions()
        ]
      )
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 30),
      onTap: () => Navigator.pop(context)
    );
  }

  Widget _buildTitle() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Text(
          "Archived notes",
          style: style.customStyle(30, fontWeight: "bold", color: Colors.white)
        )
      )
    );
  }

  Widget _buildOptions() {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert_rounded, color: Colors.white, size: 30),
      elevation: 0,
      color: Colors.grey[700],
      itemBuilder: (context) => [
        _buildPopupMenuItem(1, Icons.delete_forever_rounded, "Delete all notes"),
        _buildPopupMenuItem(2, Icons.unarchive_outlined, "Restore all notes"),
      ],
      onSelected: (value) {
        switch(value) {
          case 1:
            deleteAll();
            break;
          case 2:
            restoreAll();
            break;
          default:
            break;
        }
      }
    );
  }

  PopupMenuItem _buildPopupMenuItem(int i, IconData icon, String text) {
    return PopupMenuItem(
      value: i,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white),
          SizedBox(width: 10),
          Text(text, style: style.customStyle(18))
        ]
      )
    );
  }

  Widget _buildListView() {
    return Flexible(
      child: ValueListenableBuilder(
        valueListenable: Hive.box("archive").listenable(),
        builder: (context, labelBox, _) {
          if(Hive.box("archive").length == 0)
            return _buildEmptyText();

          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: Hive.box("archive").length,
            itemBuilder: (context, index) {
              final archiveBox = Hive.box("archive");
              final archivedNote = archiveBox.getAt(index) as Archived;

              if(archivedNote.title == "" && archivedNote.content == "")
                archiveBox.deleteAt(index);

              return _buildNotePreview(archivedNote, index);
            }
          );
        }
      )
    );
  }

  Widget _buildEmptyText() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
        child: Text("You have no archived notes!", style: style.customStyle(25, color: Colors.grey))
      )
    );
  }

  Widget _buildNotePreview(Archived note, int i) {
    return Dismissible(
      key: UniqueKey(),
      background: _buildDismissArchive(Alignment.centerLeft, Colors.green[400], Icons.unarchive_outlined),
      secondaryBackground: _buildDismissArchive(Alignment.centerRight, Colors.red[400], Icons.delete_forever),
      onDismissed: (direction) {
        if(direction == DismissDirection.startToEnd) {
          Hive.box("note").add(Note(note.title, note.content, false, note.label, note.color));
          Hive.box("archive").deleteAt(i);

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Note restored", style: style.customStyle(15)))
          );
        } else {
          Hive.box("archive").deleteAt(i);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Note deleted", style: style.customStyle(15)))
          );
        }
      },
      child: Container(
        constraints: BoxConstraints(minHeight: 50),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: style.containerDecoration(10, color: Colors.grey[400]),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: note.title != "",
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(note.title, style: style.customStyle(20, fontWeight: "bold")),
                  )
                ),

                Visibility(
                  visible: note.label != "",
                  child: Container(
                    decoration: style.containerDecoration(20, color: Colors.grey[600]),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
                      child: Text(note.label, style: style.customStyle(15))
                    )
                  )
                )
              ]
            ),

            Visibility(
              visible: note.title != "" && note.content != "",
              child: Divider(thickness: 1, color: Colors.grey[400])
            ),

            Visibility(
              visible: note.content != "" && note.label != "",
              child: SizedBox(height: 5)
            ),

            Visibility(
              visible: note.content != "",
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  note.content.length > 100
                    ? "${note.content.substring(0, 100)}..."
                    : note.content,
                  style: style.customStyle(18)
                )
              )
            )
          ]
        )
      )
    );
  }

  Widget _buildDismissArchive(Alignment alignment, Color color, IconData icon) {
    return Container(
      constraints: BoxConstraints(minHeight: 50),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: style.containerDecoration(10, background: color, color: Colors.transparent),
      child: Align(
          alignment: alignment,
          child: Icon(icon, color: Colors.white)
      )
    );
  }
}