import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../style/decoration.dart' as style;
import '../database/labels.dart';
import 'filtered_page.dart';
import 'label_page.dart';

class DrawerPage extends StatefulWidget {
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Color(0xFF424242)),
      child: Drawer(
        child: ListView(
          children: [
            _buildTitle("NOTES"),
            _buildLabelTitle(Icons.label_rounded, "Labels"),
            _buildLabelListView(),
            _buildAddLabel(),
            Divider(thickness: 1, color: Colors.white)
          ]
        )
      )
    );
  }

  Widget _buildTitle(String title) {
    return ListTile(
      title: Text(title, style: style.customStyle(25, fontWeight: "bold"))
    );
  }

  Widget _buildListTile(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, size: 30, color: Colors.white),
      title: Text(text, style: style.customStyle(20))
    );
  }

  Widget _buildLabelTitle(IconData icon, String text) {
    return ListTile(
      title: Text(text, style: style.customStyle(22)),
      trailing: GestureDetector(
        child: Text("EDIT", style: style.customStyle(16, color: Colors.grey)),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LabelPage(addNewLabel: false)
          )
        )
      )
    );
  }

  Widget _buildLabelListView() {
    return ValueListenableBuilder(
      valueListenable: Hive.box("label").listenable(),
      builder: (context, labelBox, _) {
        return ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: Hive.box("label").length,
          itemBuilder: (context, index) {
            return _buildLabelItem(index);
          }
        );
      }
    );
  }

  Widget _buildLabelItem(int i) {
    final labelBox = Hive.box("label");
    final label = labelBox.getAt(i) as Label;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FilteredPage(label, i)
        )
      ),
      child: Container(
        margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1, bottom: 10),
        child: Row(
          children: [
            Icon(Icons.label_important_outline_rounded, size: 20, color: Colors.white),
            SizedBox(width: 5),
            Text(label.label, style: style.customStyle(21))
          ]
        )
      )
    );
  }

  Widget _buildAddLabel() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LabelPage(addNewLabel: true)
        )
      ),
      child: Container(
        margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1, bottom: 5),
        child: Row(
          children: [
            Icon(Icons.add_rounded, size: 20, color: Colors.yellow[400]),
            SizedBox(width: 5),
            Text("Create a new label", style: style.customStyle(21, color: Colors.yellow[400]))
          ]
        )
      )
    );
  }
}