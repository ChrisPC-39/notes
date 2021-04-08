import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:hive/hive.dart';

import '../database/labels.dart';
import '../database/note.dart';
import '../style/decoration.dart' as style;
import 'edit_page.dart';

class FilteredPage extends StatefulWidget {
  final Label label;
  final int index;

  FilteredPage(this.label, this.index);

  @override
  _FilteredPageState createState() => _FilteredPageState();
}

class _FilteredPageState extends State<FilteredPage> {
  FocusNode titleFocusNode;
  TextEditingController titleController = TextEditingController();
  String input = "";

  @override
  void initState() {
    titleFocusNode = FocusNode();
    titleController.text = widget.label.label;
    input = widget.label.label;

    super.initState();
  }

  @override
  void dispose() {
    titleFocusNode.dispose();

    super.dispose();
  }

  void _deleteLabelAction() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Are you sure you want to delete this label?", style: style.customStyle(22)),
          backgroundColor: Color(0xFF424242),
          content: Text("This action can't be undone", style: style.customStyle(18)),
          actions: [
            TextButton(
              child: Text("Cancel", style: style.customStyle(18, color: Colors.yellow)),
              onPressed: () => Navigator.pop(context),
            ),

            TextButton(
              child: Text("Delete", style: style.customStyle(18, color: Colors.yellow)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);

                final noteBox = Hive.box("note");
                for(int i = 0; i < noteBox.length; i++) {
                  final note = noteBox.getAt(i) as Note;

                  if(note.label == widget.label.label)
                    noteBox.putAt(i, Note(note.title, note.content, note.isEditing, ""));
                }

                Hive.box("label").deleteAt(widget.index);
              }
            )
          ]
        );
      }
    );
  }

  void saveTitle() {
    Hive.box("label").putAt(widget.index, Label(input));
  }

  void saveNoteLabel() {
    final noteBox = Hive.box("note");
    for(int i = 0; i < noteBox.length; i++) {
      final note = noteBox.getAt(i) as Note;

      if(note.label == widget.label.label)
        noteBox.putAt(i, Note(note.title, note.content, note.isEditing, input));
    }
  }

  void _renameLabelAction() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Rename label", style: style.customStyle(22)),
          backgroundColor: Color(0xFF424242),
          content: TextField(
            controller: titleController,
            focusNode: titleFocusNode,
            style: TextStyle(color: Colors.white, fontSize: 18),
            onChanged: (value) => setState(() { input = value; }),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: style.customStyle(18, color: Colors.blue))
            ),

            TextButton(
              onPressed: () {
                if(_isLabelCorrect())
                  _updateLabel();
                else _throwIncorrectNameErr();
                Navigator.pop(context);

                //Refresh the current page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FilteredPage(Label(input), widget.index))
                );
              },
              child: Text("Update", style: style.customStyle(18, color: Colors.blue))
            )
          ]
        );
      }
    );
  }

  void _throwIncorrectNameErr() {
    String text = "";

    if(input == widget.label.label) text = "The label name was not changed";
    else if(input == "") text = "An error occurred:\nThe new label name is empty";
    else text = "An error occurred:\nThe new label name overlaps with an existing label";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 7),
        content: Text("$text", style: style.customStyle(16))
      )
    );
  }

  bool _isLabelCorrect() {
    if(input == "") return false;

    for(int i = 0; i < Hive.box("label").length; i++) {
      final label = Hive.box("label").getAt(i) as Label;

      if(label.label == input) return false;
    }

    return true;
  }

  void _updateLabel() {
    saveTitle();
    saveNoteLabel();
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
            widget.label.label,
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
        _buildPopupMenuItem(1, Icons.delete_rounded, "Delete label"),
        _buildPopupMenuItem(2, Icons.edit_rounded, "Rename label"),
      ],
      onSelected: (value) {
        switch(value) {
          case 1:
            _deleteLabelAction();
            break;
          case 2:
            _renameLabelAction();
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
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: Hive.box("note").length,
        itemBuilder: (context, index) {
          final note = Hive.box("note").getAt(index) as Note;

          return note.label == widget.label.label
              ? _buildOpenContainer(index)
              : Container();
        }
      )
    );
  }

  Widget _buildOpenContainer(int i) {
    final noteBox = Hive.box("note");
    final note = noteBox.getAt(i) as Note;

    return OpenContainer(
        closedElevation: 0,
        closedColor: Color(0xFF424242),
        openColor: Color(0xFF424242),

        closedBuilder: (context, action) {
          return _buildNotePreview(note);
        },

        openBuilder: (context, action) {
          return EditPage(note, i);
        }
    );
  }

  Widget _buildNotePreview(Note note) {
    return Container(
      constraints: BoxConstraints(minHeight: 50),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: style.containerDecoration(10),
      child: Column(
        children: [
          Visibility(
            visible: note.label != "",
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: style.containerDecoration(20, Colors.grey[600]),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
                  child: Text(note.label, style: style.customStyle(15))
                )
              )
            )
          ),

          Visibility(visible: note.label != "", child: Container(height: 5)),

          Visibility(
            visible: note.title != "",
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(note.title, style: style.customStyle(20, fontWeight: "bold"))
            )
          ),

          //Used for spacing
          Visibility(visible: note.title != "", child: Container(height: 5)),

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
    );
  }
}