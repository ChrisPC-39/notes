import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../style/decoration.dart' as style;
import '../database/note.dart';
import 'edit_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  TextEditingController textController = TextEditingController();
  FocusNode focusNode;
  String input = "";

  @override
  void initState() {
    focusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();

    super.dispose();
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

  void addItem(Note newNote) {
    Hive.box("note").add(Note("", "", false));
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
          backgroundColor: Color(0xFF424242),
          //drawer: DrawerPage(),
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
        addItem(Note("", "", false));
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditPage(Note("", "", false), 0)
          )
        );
      }
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        //Flexible(child: Container()),
        Flexible(child: _buildSearchBar())
      ]
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      margin: EdgeInsets.fromLTRB(5, 20, 5, 10),
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: TextField(
        style: TextStyle(color: Colors.white),
        focusNode: focusNode,
        controller: textController,
        onChanged: (String value) {
          setState(() { input = value.toLowerCase(); });
        },
        decoration: style.searchBarDecoration()
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
                  : Container(key: UniqueKey())
            ]
          );
        }
      )
    );
  }

  Widget _buildNote(int index) {
    return Dismissible(
      key: UniqueKey(),
      child: _buildOpenContainer(index),
      onDismissed: (direction) {
        setState(() { Hive.box("note").deleteAt(index); });
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
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: style.containerDecoration(),
      child: Column(
        children: [
          Visibility(
            visible: note.title != "",
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(note.title, style: style.customStyle(20, "bold"))
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

