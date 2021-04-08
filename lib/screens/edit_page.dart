import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:share/share.dart';

import '../database/note.dart';
import '../style/decoration.dart' as style;

class EditPage extends StatefulWidget {
  final Note note;
  final int index;

  EditPage(this.note, this.index);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  int _checkboxValue;
  bool editTitle = false;
  FocusNode titleFocusNode;
  FocusNode contentFocusNode;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    titleController.text = widget.note.title;
    contentController.text = widget.note.content;

    titleFocusNode = FocusNode();
    contentFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    contentFocusNode.dispose();
    titleFocusNode.dispose();

    super.dispose();
  }

  void saveContent(String value) {
    final notesBox = Hive.box("note");
    final note = notesBox.getAt(widget.index) as Note;

    notesBox.putAt(widget.index, Note(note.title, value, note.isEditing));
  }

  void saveTitle(String value) {
    final notesBox = Hive.box("note");
    final note = notesBox.getAt(widget.index) as Note;

    notesBox.putAt(widget.index, Note(value, note.content, note.isEditing));
  }

  void addItem(Note newNote) {
    Hive.box("note").add(Note("", "", false));
    final noteBox = Hive.box("note");

    for(int i = Hive.box("note").length - 1; i >= 1 ; i--) {
      final note = noteBox.getAt(i - 1) as Note;
      noteBox.putAt(i, note);
    }

    Hive.box("note").putAt(0, newNote);
  }

  /*Instead of having 2 functions for saveTitle and saveContent
  * I made this function that should work, but for some reason it doesn't...
  * If you edit the title and then click on the content to write something there,
  * the title will revert back to original for some reason. The same happens if
  * you are editing the content and switching to title. :(

  void saveNote(String value, String type) {
    final noteBox = Hive.box("note");
    final note = noteBox.getAt(widget.index) as Note;

    noteBox.putAt(widget.index, Note(
        type == "title" ? value : widget.note.title,
        type != "title" ? value : widget.note.content,
        note.isEditing)
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => setState(() { editTitle = false; contentFocusNode.unfocus(); }),
        child: Scaffold(
          backgroundColor: Color(0xFF424242),
          body: Column(
            children: [
              _buildTopBar(),
              Divider(thickness: 1),
              _buildContent()
            ]
          )
        )
      )
    );
  }

  Widget _buildTopBar(){
    return Padding(
      padding: EdgeInsets.fromLTRB(5, 20, 5, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildBackButton(),
          SizedBox(width: 10), //This is for padding
          _buildTitle(),
          _buildOptions()
        ]
      )
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 30),
      onTap: () {
        final noteBox = Hive.box("note");
        final note = noteBox.getAt(widget.index) as Note;

        if(note.title == "" && note.content == "") noteBox.deleteAt(widget.index);
        Navigator.pop(context);
      }
    );
  }

  Widget _buildTitle() {
    final notesBox = Hive.box("note");
    final note = notesBox.getAt(widget.index) as Note;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            editTitle = true;
            titleController.text = note.title;
            titleFocusNode.requestFocus();
            contentFocusNode.unfocus();
          });
        },
        child: editTitle
          ? TextField(
            style: style.customStyle(30, fontWeight: "bold"),
            focusNode: titleFocusNode,
            controller: titleController,
            onChanged: (String value) { saveTitle(value); },
            decoration: style.editPageDecoration(true)
          )
          : Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text(
              note.title == "" ? "Title" : note.title,
              style: style.customStyle(30, fontWeight: "bold", color: note.title == "" ? Colors.grey : Colors.white)
            )
          )
      ),
    );
  }

  Widget _buildOptions() {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert_rounded, color: Colors.white, size: 30),
      elevation: 0,
      color: Colors.grey[700],
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Text("Delete", style: style.customStyle(18))
        ),

        PopupMenuItem(
          value: 2,
          child: Text("Undo changes", style: style.customStyle(18))
        ),

        PopupMenuItem(
          value: 3,
          child: Text("Duplicate", style: style.customStyle(18))
        ),

        PopupMenuItem(
          value: 4,
          child: Text("Share", style: style.customStyle(18))
        )
      ],
      onSelected: (value) {
        switch(value) {
          case 1:
            _deleteAction();
            break;
          case 2:
            _undoAction();
            break;
          case 3:
            _duplicateAction();
            break;
          case 4:
            _shareAction();
            break;
          default: break;
        }
      }
    );
  }

  void _deleteAction() {
    Navigator.pop(context);

    Future.delayed(Duration(milliseconds: 200), () {
      Hive.box("note").deleteAt(widget.index);
    });
  }

  void _undoAction() {
    titleController.text = widget.note.title;
    contentController.text = widget.note.content;

    Hive.box("note").putAt(
      widget.index,
      Note(widget.note.title, widget.note.content, widget.note.isEditing)
    );
    setState(() {});
  }

  void _duplicateAction() {
    addItem(Note(
      titleController.text,
      contentController.text,
      false
    ));
  }

  void _shareAction() {
    Share.share(
      "${widget.note.title}\n"
      "${widget.note.content}"
    );
  }

  Widget _buildContent() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: TextField(
        maxLines: null,
        style: TextStyle(color: Colors.white),
        focusNode: contentFocusNode,
        controller: contentController,
        onChanged: (String value) { saveContent(value); },
        decoration: style.editPageDecoration(false, "Note")
      )
    );
  }
}