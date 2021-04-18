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
    widget.note.label != "" ? radioIndex = findRadioIndex() : radioIndex = -1;

    if(widget.note.label != "") {
      Hive.box("note").putAt(
          widget.index,
          Note(widget.note.title, widget.note.content, widget.note.isEditing, widget.note.label)
      );
    }

    saveContent(contentController.text);

    titleFocusNode = FocusNode();
    contentFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    // contentFocusNode.dispose();
    // titleFocusNode.dispose();

    super.dispose();
  }

  int findRadioIndex() {
    final labelBox = Hive.box("label");

    for(int i = 0; i < labelBox.length; i++) {
      final label = labelBox.getAt(i) as Label;

      if(label.label == widget.note.label) return i;
    }

    return -1;
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
      "${titleController.text}\n"
      "${contentController.text}"
    );
  }

  void _addLabelAction() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select a label", style: style.customStyle(22)),
          backgroundColor: Color(0xFF424242),
          content: Hive.box("label").length == 0
              ? Text("You have no labels yet", style: style.customStyle(16))
              : _buildLabelListView(),
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

  void _removeLabelAction() {
    if(widget.note.label != "") {
      final newNote = Note(titleController.text, contentController.text, widget.note.isEditing, "");

      Hive.box("note").putAt(widget.index, newNote);

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => EditPage(newNote, widget.index),
          transitionDuration: Duration(seconds: 0)
        )
      );
    }
  }

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
              _buildContent(),
              _buildLabel(),
              Spacer(flex: 1),
              //_buildNavBar()
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
          SizedBox(width: 15), //This is for padding
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
            decoration: style.editPageDecoration(true),
            textCapitalization: TextCapitalization.sentences,
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
        _buildPopupMenuItem(5, Icons.label_rounded, "Label"),
        _buildPopupMenuItem(6, Icons.label_off_rounded, "Remove label")
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
            _addLabelAction();
            break;
          case 6:
            _removeLabelAction();
            break;
          default: break;
        }
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
      )
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
      selectedTileColor: Colors.white,
      onChanged: (value) => setState(() {
        radioIndex = value;
        Navigator.pop(context);

        final newNote = Note(titleController.text, contentController.text, widget.note.isEditing, label.label);
        Hive.box("note").putAt(widget.index, newNote);

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => EditPage(newNote, widget.index),
            transitionDuration: Duration(seconds: 0)
          )
        );
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
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(color: Colors.white, fontSize: 20),
        focusNode: contentFocusNode,
        controller: contentController,
        onChanged: (String value) { saveContent(value); },
        decoration: style.editPageDecoration(false, "Note")
      )
    );
  }

  Widget _buildLabel() {
    if(widget.note.label != "") {
      return Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          margin: EdgeInsets.only(left: 10),
          decoration: style.containerDecoration(20, color: Colors.grey[600]),
          child: Padding(
            padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
            child: Text(widget.note.label, style: style.customStyle(18))
          )
        )
      );
    } else {
      return Align(
        alignment: Alignment.bottomLeft,
        child: GestureDetector(
          onTap: () => _addLabelAction(),
          child: Container(
            margin: EdgeInsets.only(left: 10),
            decoration: style.containerDecoration(20, color: Colors.grey[600]),
            child: Padding(
              padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
              child: Icon(Icons.add, color: Colors.white54)
            )
          )
        )
      );
    }
  }

  Widget _buildNavBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      backgroundColor: Color(0xFF424242),
      items: [
        _buildNavBarItem(Icons.title, "Update title"),
        _buildNavBarItem(Icons.note_add_outlined, "Update note"),
        _buildNavBarItem(Icons.label, "Update label")
      ],
      onTap: (index) {
        switch(index) {
          case 0:
            contentFocusNode.unfocus();
            titleFocusNode.requestFocus();
            break;
          case 1:
            titleFocusNode.unfocus();
            contentFocusNode.requestFocus();
            break;
          case 2:
            _addLabelAction();
            break;
          default:
            break;
        }
      }
    );
  }

  BottomNavigationBarItem _buildNavBarItem(IconData icon, String text) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: text
    );
  }
}