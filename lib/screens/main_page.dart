import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../style/decoration.dart' as style;
import '../database/note.dart';
import 'drawer_page.dart';
import 'edit_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  TextEditingController textController = TextEditingController();
  FocusNode focusNode;

  double searchBarWidth;
  String input = "";

  Note deletedNote;

  @override
  void initState() {
    focusNode = FocusNode();
    focusNode.addListener(() { isTextFieldFocused(); });

    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();

    super.dispose();
  }

  bool isTextFieldFocused() {
    return focusNode.hasFocus;
  }

  void reorderList(int oldIndex, int newIndex) {
    final noteBox = Hive.box('note');
    final note = noteBox.getAt(oldIndex);

    if (oldIndex > newIndex) {
      for (int i = oldIndex; i > newIndex; i--) {
        final note = noteBox.getAt(i - 1) as Note;
        noteBox.putAt(i, note);
      }

      noteBox.putAt(newIndex, note);
    } else if (oldIndex < newIndex) {
      for (int i = oldIndex; i < newIndex - 1; i++) {
        final note = noteBox.getAt(i + 1) as Note;
        noteBox.putAt(i, note);
      }

      noteBox.putAt(newIndex - 1, note);
    }
  }

  void addNote(Note newNote) {
    Hive.box("note").add(Note("", "", false, ""));
    final noteBox = Hive.box("note");

    for(int i = Hive.box("note").length - 1; i >= 1 ; i--) {
      final note = noteBox.getAt(i - 1) as Note;
      noteBox.putAt(i, note);
    }

    Hive.box("note").putAt(0, newNote);
  }

  bool doNotesContainInput(int i) {
    final notesBox = Hive.box("note");
    final note = notesBox.getAt(i) as Note;

    return note.title.toLowerCase().contains(input)
           || note.content.toLowerCase().contains(input);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => focusNode.unfocus(),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Color(0xFF424242),
          drawer: DrawerPage(),
          floatingActionButton: _buildFloatingWidget(),
          body: Column(
            children: [
              _buildTopBar(),
              _buildListView()
            ]
          )
        )
      )
    );
  }

  Widget _buildFloatingWidget() {
    return FloatingActionButton(
      backgroundColor: Colors.yellow[400],
      child: Icon(Icons.add_rounded, color: Color(0xFF424242), size: 30),
      onPressed: () {
        addNote(Note("", "", false, ""));
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditPage(Note("", "", false, ""), 0)
          )
        );
      }
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _buildDrawerButton(),
        Flexible(child: _buildSearchBar())
      ]
    );
  }

  Widget _buildDrawerButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 20, 5, 10),
      child: GestureDetector(
        child: Icon(Icons.menu_rounded, size: 30, color: Colors.white),
        onTap: () => _scaffoldKey.currentState.openDrawer()
      )
    );
  }

  Widget _buildSearchBar() {
    if(isTextFieldFocused())
      searchBarWidth = MediaQuery.of(context).size.width * 0.70;
    else searchBarWidth = MediaQuery.of(context).size.width * 0.845;
    setState(() {});

    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      margin: EdgeInsets.fromLTRB(5, 20, 0, 10),
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Row(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            width: searchBarWidth,
            child: TextField(
              style: TextStyle(color: Colors.white),
              focusNode: focusNode,
              controller: textController,
              decoration: style.searchBarDecoration(),
              onChanged: (String value) {
                setState(() { input = value.toLowerCase(); });
              }
            )
          ),

          Visibility(
            visible: isTextFieldFocused(),
            child: Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 5),
                child: GestureDetector(
                  child: Text("Cancel", style: style.customStyle(16, color: Colors.blue[400]), maxLines: 1),
                  onTap: () => setState(() {
                    textController.text = "";
                    input = "";
                    focusNode.unfocus();
                  })
                )
              )
            )
          )
        ]
      )
    );
  }

  Widget _buildListView() {
    return Flexible(
      child: ValueListenableBuilder(
        valueListenable: Hive.box("note").listenable(),
        builder: (context, noteBox, _) {
          return ReorderableListView(
            physics: BouncingScrollPhysics(),
            key: listKey,
            onReorder: reorderList,
            children: [
              for(int i = 0; i < Hive.box("note").length; i++)
                doNotesContainInput(i)
                  ? _buildNote(i)
                  : _buildNoteNotFound(i),

              if(Hive.box("note").length == 0)
                _buildEmptyText()
            ]
          );
        }
      )
    );
  }

  Widget _buildNoteNotFound(int i) {
    return Visibility(
      key: UniqueKey(),
      visible: i == 0,
      child: GestureDetector(
        child: Container(
          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.3, bottom: 5),
          child: Row(
            children: [
              Icon(Icons.add_rounded, size: 25, color: Colors.yellow[400]),
              Text("Create new note", style: style.customStyle(18))
            ]
          )
        ),
        onTap: () {
          addNote(Note("", "", false, ""));
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditPage(Note("", input, false, ""), 0)
            )
          );
        }
      )
    );
  }

  Widget _buildEmptyText() {
    return Center(
      key: UniqueKey(),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          children: [
            Text("You don't have any notes yet", style: style.customStyle(25, color: Colors.grey)),
            Text("Tap here to create one!", style: style.customStyle(25, color: Colors.grey)),
            Padding(
              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.5, top: 7),
              child: Icon(Icons.subdirectory_arrow_right_rounded, size: 40, color: Colors.grey),
            )
          ]
        )
      )
    );
  }

  Widget _buildNote(int index) {
    return Dismissible(
      key: UniqueKey(),
      child: _buildOpenContainer(index),
      onDismissed: (direction) {
        deletedNote = Hive.box("note").getAt(index) as Note;
        setState(() { Hive.box("note").deleteAt(index); });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Note deleted", style: style.customStyle(15)),
                TextButton(
                  child: Text("UNDO", style: style.customStyle(15, color: Colors.yellow[400])),
                  onPressed: () {
                    addNote(deletedNote);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  }
                )
              ]
            )
          )
        );
      }
    );
  }

  Widget _buildOpenContainer(int index) {
    final noteBox = Hive.box("note");
    final note = noteBox.getAt(index) as Note;

    return OpenContainer(
      closedElevation: 0,
      closedColor: Color(0xFF424242),
      openColor: Color(0xFF424242),

      closedBuilder: (context, action) {
        return _buildNotePreview(note);
      },

      openBuilder: (context, action) {
        return EditPage(note, index);
      }
    );
  }

  Widget _buildNotePreview(Note note) {
    return Container(
      constraints: BoxConstraints(minHeight: 50),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: style.containerDecoration(10, Colors.grey[400]),
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
                  decoration: style.containerDecoration(20, Colors.grey[600]),
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

