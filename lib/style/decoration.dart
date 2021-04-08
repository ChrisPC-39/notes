import 'package:flutter/material.dart';

InputDecoration searchBarDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: Colors.grey[700],
    enabledBorder: outlineBorder(),
    focusedBorder: outlineBorder(),

    prefixIcon: Icon(Icons.search, color: Colors.white),
    labelText: "Search for a note",
    labelStyle: TextStyle(color: Colors.white)
  );
}

InputDecoration editPageDecoration(bool isDense, [String labelText = ""]) {
  return InputDecoration(
    isDense: isDense,
    enabledBorder: outlineBorder(),
    focusedBorder: outlineBorder(),

    labelText: labelText,
    labelStyle: TextStyle(color: Colors.grey)
  );
}

InputDecoration addLabelDecoration(String labelText) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.grey[700],
    enabledBorder: outlineBorder(),
    focusedBorder: outlineBorder(),

    labelText: labelText,
    labelStyle: TextStyle(color: Colors.white)
  );
}

OutlineInputBorder outlineBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.all(Radius.circular(20))
  );
}

BoxDecoration containerDecoration(double radius, [Color color = Colors.grey]) {
  return BoxDecoration(
    border: Border.all(color: color, width: 2),
    borderRadius: BorderRadius.all(Radius.circular(radius))
  );
}

TextStyle customStyle(double size, {String fontWeight = "normal", Color color = Colors.white}) {
  return TextStyle(
    fontSize: size,
    fontWeight: fontWeight == "bold" ? FontWeight.bold : FontWeight.normal,
    color: color
  );
}