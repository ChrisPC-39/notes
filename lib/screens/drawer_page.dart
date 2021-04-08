import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../style/decoration.dart' as style;
import '../database/labels.dart';
import 'filtered_page.dart';
import 'label_page.dart';

class DrawerPage extends StatefulWidget {
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  static const _privacyPolicyURL = 'https://github.com/ChrisPC-39/Privacy-and-TOS/blob/main/Privacy-Policy.txt';
  static const _githubURL = "https://github.com/ChrisPC-39/notes";
  static const _googlePlayURL = "https://play.google.com/store/apps/details?id=com.notes.exo";

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Color(0xFF424242)),
      child: Drawer(
        child: ListView(
          children: [
            _buildTitle("Handy notes"),
            _buildLabelTitle(Icons.label_rounded, "Labels"),
            _buildLabelListView(),
            _buildAddLabel(),
            Divider(thickness: 1, color: Colors.white),
            _buildListTile(Icons.privacy_tip_outlined, "Privacy and Policy", _privacyPolicyURL),
            _buildListTile(Icons.call_split_rounded, "Github link", _githubURL)
          ]
        )
      )
    );
  }

  Widget _buildTitle(String title) {
    return ListTile(
      leading: Icon(Icons.notes_rounded, color: Colors.white, size: 25),
      title: RichText(
        text: TextSpan(
          text: title,
          style: style.customStyle(20, fontWeight: "bold"),
          recognizer: TapGestureRecognizer()..onTap = () => launch(_googlePlayURL)
        )
      )
    );
  }

  Widget _buildListTile(IconData icon, String text, String url) {
    return ListTile(
      leading: Icon(icon, size: 30, color: Colors.white),
      title: RichText(
        text: TextSpan(
          text: text,
          style: style.customStyle(20),
          recognizer: TapGestureRecognizer()..onTap = () => launch(url)
        )
      )
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