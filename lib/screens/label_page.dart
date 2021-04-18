import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes/database/note.dart';

import '../database/labels.dart';
import '../style/decoration.dart' as style;
import 'filtered_page.dart';

class LabelPage extends StatefulWidget {
  final bool addNewLabel;
  final bool selectLabel;

  LabelPage({this.addNewLabel = false, this.selectLabel = false});

  @override
  _LabelPageState createState() => _LabelPageState();
}

class _LabelPageState extends State<LabelPage> {
  TextEditingController textController = TextEditingController();
  FocusNode focusNode;

  double searchBarWidth;
  String input = "";
  bool addNewLabel = false;

  @override
  void initState() {
    addNewLabel = widget.addNewLabel;
    focusNode = FocusNode();
    focusNode.addListener(() { isTextFieldFocused(); });

    super.initState();
  }

  // @override
  // void dispose() {
  //   focusNode.dispose();
  //
  //   super.dispose();
  // }

  bool isTextFieldFocused() {
    return focusNode.hasFocus;
  }

  bool _isLabelCorrect() {
    if(input == "") return false;

    for(int i = 0; i < Hive.box("label").length; i++) {
      final label = Hive.box("label").getAt(i) as Label;

      if(label.label == input) return false;
    }

    return true;
  }

  void _throwIncorrectNameErr() {
    String text = "";

    if(input == "") text = "An error occurred:\nThe new label name is empty";
    else text = "An error occurred:\nThe new label name overlaps with an existing label";

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            duration: Duration(seconds: 7),
            content: Text("$text", style: style.customStyle(16))
        )
    );
  }

  void addLabel(Label newLabel) {
    Hive.box("label").add(Label(""));
    final labelBox = Hive.box("label");

    for(int i = Hive.box("label").length - 1; i >= 1 ; i--) {
      final label = labelBox.getAt(i - 1) as Label;
      labelBox.putAt(i, label);
    }

    Hive.box("label").putAt(0, newLabel);
  }

  @override
  Widget build(BuildContext context) {
    if(addNewLabel) {
      focusNode.requestFocus();
      setState(() { addNewLabel = false; });
    }
    return SafeArea(
      child: GestureDetector(
        onTap: () => focusNode.unfocus(),
        child: Scaffold(
          backgroundColor: Color(0xFF424242),
          body: Column(
            children: [
              _buildTopBar(),
              _buildListView(),
              _buildNavBar()
            ]
          )
        ),
      )
    );
  }

  Widget _buildTopBar() {
    if(isTextFieldFocused())
      searchBarWidth = MediaQuery.of(context).size.width * 0.60;
    else searchBarWidth = MediaQuery.of(context).size.width * 0.845;
    setState(() {});

    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      margin: EdgeInsets.fromLTRB(5, 20, 0, 10),
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Row(
        children: [
          _buildBackButton(),
          SizedBox(width: 10),
          _buildSearchBar(),
          _buildAddButton(),
          _buildCancelButton()
        ]
      )
    );
  }

  _buildBackButton() {
    return GestureDetector(
      child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 30),
      onTap: () => Navigator.pop(context)
    );
  }

  _buildSearchBar() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      width: searchBarWidth,
      child: TextField(
        style: TextStyle(color: Colors.white),
        focusNode: focusNode,
        controller: textController,
        textCapitalization: TextCapitalization.sentences,
        decoration: style.addLabelDecoration("Search or add a new label"),
        onChanged: (String value) {
          setState(() { input = value; });
        }
      )
    );
  }

  Widget _buildAddButton() {
    return Visibility(
      visible: isTextFieldFocused(),
      child: Expanded(
        child: Center(
          child: Container(
            child: GestureDetector(
              child: Text("Add", style: style.customStyle(16, color: Colors.blue[400]), maxLines: 1),
              onTap: () => setState(() {
                if(_isLabelCorrect())
                  addLabel(Label(input));
                else _throwIncorrectNameErr();

                textController.text = "";
                input = "";
                focusNode.unfocus();
              })
            )
          )
        )
      )
    );
  }

  Widget _buildCancelButton() {
    return Visibility(
      visible: isTextFieldFocused(),
      child: Expanded(
        child: Container(
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
    );
  }

  Widget _buildListView() {
    return Flexible(
      child: ValueListenableBuilder(
        valueListenable: Hive.box("label").listenable(),
        builder: (context, labelBox, _) {
          if(Hive.box("label").length == 0)
            return _buildEmptyText();

          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: Hive.box("label").length,
            itemBuilder: (context, index) {
              final label = Hive.box("label").getAt(index) as Label;

              return label.label.toLowerCase().contains(input.toLowerCase())
                ? _buildOpenContainer(index)
                : Container();
            }
          );
        }
      )
    );
  }

  Widget _buildEmptyText() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.5),
        child: Column(
          children: [
            Text("You don't have any labels yet", style: style.customStyle(25, color: Colors.grey)),
            Text("Tap the \"+\" button to create one!", style: style.customStyle(25, color: Colors.grey))
          ]
        ),
      )
    );
  }

  Widget _buildOpenContainer(int i) {
    final labelBox = Hive.box("label");
    final label = labelBox.getAt(i) as Label;

    return OpenContainer(
        closedElevation: 0,
        closedColor: Color(0xFF424242),
        openColor: Color(0xFF424242),

        closedBuilder: (context, action) {
          return _buildLabelPreview(label, i);
        },

        openBuilder: (context, action) {
          return FilteredPage(label, i);
        }
    );
  }

  Widget _buildLabelPreview(Label label, int index) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        Label labelCopy = label;
        List<int> indices = [];

        for(int i = 0; i < Hive.box("note").length; i++) {
          final note = Hive.box("note").getAt(i) as Note;

          if(note.label == label.label) {
            Hive.box("note").putAt(i, Note(note.title, note.content, false, ""));
            indices.add(i);
          }
        }

        Hive.box("label").deleteAt(index);

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Label deleted", style: style.customStyle(15)),
                TextButton(
                  child: Text("UNDO", style: style.customStyle(15, color: Colors.yellow[400])),
                  onPressed: () {
                    Hive.box("label").add(Label(labelCopy.label));

                    for(int i = 0; i < indices.length; i++) {
                      final note = Hive.box("note").getAt(indices[i]) as Note;
                      Hive.box("note").putAt(indices[i], Note(note.title, note.content, false, labelCopy.label));
                    }

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  }
                )
              ]
            )
          )
        );
      },
      background: _buildDismissLabel(Alignment.centerLeft),
      secondaryBackground: _buildDismissLabel(Alignment.centerRight),
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Row(
          children: [
            Icon(Icons.label_important_outline_rounded, size: 30, color: Colors.white),
            SizedBox(width: 5),
            Text(label.label, style: style.customStyle(25))
          ]
        )
      )
    );
  }

  Widget _buildDismissLabel(Alignment alignment) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: style.containerDecoration(10, background: Colors.red[400], color: Colors.transparent),
      child: Align(
        alignment: alignment,
        child: Icon(Icons.delete_forever, color: Colors.white)
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
        _buildNavBarItem(Icons.search, "Search"),
        _buildNavBarItem(Icons.add_rounded, "Add")
      ],
      onTap: (index) {
        switch(index) {
          case 0:
            navBack();
            break;
          case 1:
            navSearch();
            break;
          case 2:
            navAdd();
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

  void navSearch() {
    focusNode.requestFocus();
  }

  void navAdd() {
    if(textController.text.isEmpty)
      focusNode.requestFocus();
    else addLabel(Label(input));
  }

  BottomNavigationBarItem _buildNavBarItem(IconData icon, String text) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: text
    );
  }
}