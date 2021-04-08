import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notes/database/labels.dart';
import 'package:share/share.dart';

import '../database/note.dart';
import '../style/decoration.dart' as style;
import '../database/labels.dart';

class EditPage extends StatefulWidget {
  final Note note;
  final int index;

  EditPage(this.note, this.index);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  int radioIndex = -1;
  bool editTitle = false;
  FocusNode titleFocusNode;
  FocusNode contentFocusNode;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    titleController.text = widget.note.title;
    contentController.text = widget.note.content;

    saveContent(contentController.text);

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

    notesBox.putAt(widget.index, Note(note.title, value, note.isEditing, note.label));
  }

  void saveTitle(String value) {
    final notesBox = Hive.box("note");
    final note = notesBox.getAt(widget.index) as Note;

    notesBox.putAt(widget.index, Note(value, note.content, note.isEditing, note.label));
  }

  void addItem(Note newNote) {
    Hive.box("note").add(Note("", "", false, ""));
    final noteBox = Hive.box("note");

    for(int i = Hive.box("note").length - 1; i >= 1 ; i--) {
      final note = noteBox.getAt(i - 1) as Note;
      noteBox.putAt(i, note);
    }

    Hive.box("note").putAt(0, newNote);
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
      Note(widget.note.title, widget.note.content, widget.note.isEditing, widget.note.label)
    );
    setState(() {});
  }

  void _duplicateAction() {
    addItem(Note(
      titleController.text,
      contentController.text,
      false,
      ""
    ));
  }

  void _shareAction() {
    Share.share(
      "${widget.note.title}\n"
      "${widget.note.content}"
    );
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
              Divider(thickness: 1, color: Colors.white),
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
        _buildPopupMenuItem(1, Icons.delete_rounded, "Delete"),
        _buildPopupMenuItem(2, Icons.undo_rounded, "Revert to original"),
        _buildPopupMenuItem(3, Icons.copy_rounded, "Duplicate"),
        _buildPopupMenuItem(4, Icons.share_rounded, "Share"),
        _buildPopupMenuItem(5, Icons.label_rounded, "Label")
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
          case 5:
            _labelAction();
            break;
          default: break;
        }
      }
    );
  }

  void _labelAction() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select a label", style: style.customStyle(22)),
          backgroundColor: Color(0xFF424242),
          content: _buildLabelListView(),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: style.customStyle(18, color: Colors.blue))
            )
          ]
        );
      }
    );
  }

  Widget _buildLabelListView() {
    return Container(
      width: 200,
      height: 200,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: Hive.box("label").length,
        itemBuilder: (context, index) {
          return _buildSelectableLabel(index);
        }
      ),
    );
  }

  Widget _buildSelectableLabel(int i) {
    final labelBox = Hive.box("label");
    final label = labelBox.getAt(i) as Label;

    return RadioListTile(
      title: Text(label.label, style: style.customStyle(16)),
      value: i,
      toggleable: true,
      groupValue: radioIndex,
      activeColor: Colors.white,
      onChanged: (value) => setState(() {
        radioIndex = value;
        Hive.box("note").putAt(
          widget.index,
          Note(widget.note.title, widget.note.content, widget.note.isEditing, label.label)
        );
        Navigator.pop(context);
      })
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