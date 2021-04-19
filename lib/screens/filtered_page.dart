import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_colorpicker/material_picker.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:hive/hive.dart';
import 'package:notes/database/archived.dart';

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
  String input = "";
  int radioIndex = -1;
  FocusNode titleFocusNode;
  Color pickerColor = Color(0xFF757575);
  TextEditingController titleController = TextEditingController();

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

  void addNote(Note newNote) {
    Hive.box("note").add(Note("", "", false, "", 0xFFFFFFFF));
    final noteBox = Hive.box("note");

    for(int i = Hive.box("note").length - 1; i >= 1 ; i--) {
      final note = noteBox.getAt(i - 1) as Note;
      noteBox.putAt(i, note);
    }

    Hive.box("note").putAt(0, newNote);
  }

  void _removeLabelAction(int noteIndex) {
    final note = Hive.box("note").getAt(noteIndex) as Note;

    if(note.label != "") {
      final newNote = Note(note.title, note.content, false, "", 0xFFFFFFFF);

      Hive.box("note").putAt(noteIndex, newNote);
    }
  }

  void _addLabelAction(int noteIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select a label", style: style.customStyle(22)),
          backgroundColor: Color(0xFF424242),
          content: Hive.box("label").length == 0
            ? Text("You have no labels yet", style: style.customStyle(16))
            : _buildLabelListView(noteIndex),
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
                    noteBox.putAt(i, Note(note.title, note.content, note.isEditing, "", 0xFFFFFFFF));
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
    Hive.box("label").putAt(widget.index, Label(input, 0xFFFFFFFF));
  }

  void saveNoteLabel() {
    final noteBox = Hive.box("note");
    for(int i = 0; i < noteBox.length; i++) {
      final note = noteBox.getAt(i) as Note;

      if(note.label == widget.label.label)
        noteBox.putAt(i, Note(note.title, note.content, note.isEditing, input, note.labelColor));
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
            textCapitalization: TextCapitalization.sentences,
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
                  PageRouteBuilder(
                    pageBuilder: (context, anim1, anim2) => FilteredPage(Label(input, 0xFFFFFFFF), widget.index),
                    transitionDuration: Duration(seconds: 0)
                  )
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
            _buildListView(),
            _buildNavBar()
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
        _buildPopupMenuItem(3, Icons.color_lens, "Change label color")
      ],
      onSelected: (value) {
        switch(value) {
          case 1:
            _deleteLabelAction();
            break;
          case 2:
            _renameLabelAction();
            break;
          case 3:
            _changeColorAction();
            break;
          default:
            break;
        }
      }
    );
  }

  void _changeColorAction() {
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: AlertDialog(
            backgroundColor: Color(0xFF424242),
            title: Text("Pick a color", style: style.customStyle(18)),
            content: MaterialPicker(
              pickerColor: pickerColor,
              onColorChanged: _changeColor
            ),
            actions: [
              TextButton(
                child: Text("Cancel", style: style.customStyle(18, color: Colors.blue)),
                onPressed: () => Navigator.pop(context)
              ),

              TextButton(
                child: Text("Done", style: style.customStyle(18, color: Colors.blue)),
                onPressed: () {
                  setState(() {
                    for(int i = 0; i < Hive.box("note").length; i++) {
                      final note = Hive.box("note").getAt(i) as Note;

                      if(note.label == widget.label.label)
                        Hive.box("note").putAt(i, Note(note.title, note.content, note.isEditing, note.label, pickerColor.value));
                    }

                    for(int i = 0; i < Hive.box("label").length; i++) {
                      final label = Hive.box("label").getAt(i) as Label;

                      if(label.label == widget.label.label)
                        Hive.box("label").putAt(i, Label(label.label, pickerColor.value));
                    }

                    Navigator.pop(context);
                  });
                }
              )
            ]
          )
        );
      }
    );
  }

  void _changeColor(Color color) {
    setState(() => pickerColor = color);
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
            ? _buildNote(index)
            : Container();
        }
      )
    );
  }

  Widget _buildNote(int index) {
    return FocusedMenuHolder(
      key: UniqueKey(),
      animateMenuItems: false,
      menuWidth: MediaQuery.of(context).size.width,
      onPressed: () {},
      menuItems: [
        _buildFocusedMenuItem("Add label", Icons.label, () => _addLabelAction(index)),
        _buildFocusedMenuItem("Remove label", Icons.label_off, () => _removeLabelAction(index)),
        _buildFocusedMenuItem("Archive", Icons.archive,
                () => dismissNote(index), background: Colors.green[400]
        ),
        _buildFocusedMenuItem("Delete permanently", Icons.delete_forever_rounded,
                () { Hive.box("note").deleteAt(index); setState(() {}); }, background: Colors.red[400]
        )
      ],
      child: Dismissible(
          key: UniqueKey(),
          child: _buildOpenContainer(index),
          background: _buildDismissArchive(Alignment.centerLeft),
          secondaryBackground: _buildDismissArchive(Alignment.centerRight),
          onDismissed: (direction) => dismissNote(index)
      )
    );
  }

  void dismissNote(int index) {
    Note deletedNote = Hive.box("note").getAt(index) as Note;
    Hive.box("archive").add(Archived(deletedNote.title, deletedNote.content, deletedNote.label, deletedNote.labelColor));
    setState(() { Hive.box("note").deleteAt(index); });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Note archived", style: style.customStyle(15)),
            TextButton(
              child: Text("UNDO", style: style.customStyle(15, color: Colors.yellow[400])),
              onPressed: () {
                addNote(deletedNote);
                Hive.box("archive").deleteAt(Hive.box("archive").length - 1);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                setState(() {});
              }
            )
          ]
        )
      )
    );
  }

  Widget _buildLabelListView(int noteIndex) {
    return Container(
      width: 200,
      height: 200,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: Hive.box("label").length,
        itemBuilder: (context, index) {
          return _buildSelectableLabel(index, noteIndex);
        }
      )
    );
  }

  Widget _buildSelectableLabel(int i, int noteIndex) {
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

        final note = Hive.box("note").getAt(noteIndex) as Note;
        final newNote = Note(note.title, note.content, false, label.label, label.color);
        Hive.box("note").putAt(noteIndex, newNote);
      })
    );
  }

  Widget _buildDismissArchive(Alignment alignment) {
    return Container(
      constraints: BoxConstraints(minHeight: 50),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: style.containerDecoration(10, background: Colors.green[400], color: Colors.transparent),
      child: Align(
        alignment: alignment,
        child: Icon(Icons.archive_rounded, color: Colors.white)
      )
    );
  }

  FocusedMenuItem _buildFocusedMenuItem(String title, IconData icon, Function _onTap, {Color color = Colors.black, Color background = Colors.white}) {
    return FocusedMenuItem(
      backgroundColor: background,
      title: Text(title, style: style.customStyle(18, color: color, fontWeight: "bold")),
      trailingIcon: Icon(icon, size: 22, color: color),
      onPressed: _onTap
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
                  decoration: style.containerDecoration(20, color: Color(note.labelColor)),
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
    );
  }

  Widget _buildNavBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      backgroundColor: Color(0xFF424242),
      items: [
        _buildNavBarItem(Icons.arrow_back_ios_rounded, "Back"),
        _buildNavBarItem(Icons.add_rounded, "Add")
      ],
      onTap: (index) {
        switch(index) {
          case 0:
            navBack();
            break;
          case 1:
            navAddButton();
            break;
          default:
            break;
        }
      }
    );
  }

  void navBack() {
    Navigator.pop(context);
  }

  void navAddButton() {
    addNote(Note("", "", false, "", 0xFFFFFFFF));
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditPage(Note("", "", false, widget.label.label, widget.label.color), 0)
      )
    );
    setState(() {});
  }

  BottomNavigationBarItem _buildNavBarItem(IconData icon, String text) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: text
    );
  }
}