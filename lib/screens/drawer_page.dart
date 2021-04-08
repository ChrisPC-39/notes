import 'package:flutter/material.dart';

import '../style/decoration.dart' as style;

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
            _buildListTile(Icons.ac_unit, "Text")
          ]
        )
      )
    );
  }

  Widget _buildListTile(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, size: 30, color: Colors.white),
      title: Text(text, style: style.customStyle(20))
    );
  }
}