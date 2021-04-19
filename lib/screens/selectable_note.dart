import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notes/database/labels.dart';
import 'package:notes/database/note.dart';
import '../style/decoration.dart' as style;

class SelectablePage extends StatefulWidget {
  final Label label;

  SelectablePage(this.label);

  @override
  _SelectablePageState createState() => _SelectablePageState();
}

class _SelectablePageState extends State<SelectablePage> {
  List<int> selectedNotes = [];

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
          _buildConfirm()
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
          "Select notes",
          style: style.customStyle(30, fontWeight: "bold", color: Colors.white)
        )
      )
    );
  }

  Widget _buildConfirm() {
    return GestureDetector(
      onTap: () => _labelNotes(),
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: Icon(Icons.check, size: 30, color: Colors.white),
      )
    );
  }

  void _labelNotes() {
    for(int i = 0; i < selectedNotes.length; i++) {
      final n = Hive.box("note").getAt(selectedNotes[i]) as Note;
      Hive.box("note").putAt(selectedNotes[i], Note(n.title, n.content, false, widget.label.label, widget.label.color));

      if(n.label != "")
        Hive.box("note").putAt(selectedNotes[i], Note(n.title, n.content, false, "", 0xFF757575));
    }

    setState(() { selectedNotes.clear(); });
  }

  Widget _buildListView() {
    return Flexible(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: Hive.box("note").length,
        itemBuilder: (context, index) {
          final note = Hive.box("note").getAt(index) as Note;

          return _buildNotePreview(note, index);
        }
      )
    );
  }

  Widget _buildNotePreview(Note note, int index) {
    return GestureDetector(
      onTap: () => selectNote(index),
      child: Container(
        constraints: BoxConstraints(minHeight: 50),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: style.containerDecoration(10, color: selectedNotes.contains(index) ? Colors.white : Colors.grey[400]),
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
      ),
    );
  }

  void selectNote(int index) {
    setState(() {
      if(selectedNotes.contains(index))
        selectedNotes.remove(index);
      else selectedNotes.add(index);
    });
  }

  Widget _buildNavBar() {
    return BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        backgroundColor: Color(0xFF424242),
        items: [
          _buildNavBarItem(Icons.arrow_back_ios_rounded, "Back"),
          _buildNavBarItem(Icons.check_box_outline_blank, "Clear selection"),
          _buildNavBarItem(Icons.check, "Confirm selection")
        ],
        onTap: (index) {
          switch(index) {
            case 0:
              navBack();
              break;
            case 1:
              navClearSelection();
              break;
            case 2:
              _labelNotes();
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

  void navClearSelection() {
    setState(() {
      selectedNotes.clear();
    });
  }

  BottomNavigationBarItem _buildNavBarItem(IconData icon, String text) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: text
    );
  }
}