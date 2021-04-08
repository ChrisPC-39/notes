import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:notes/database/labels.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'database/note.dart';
import 'screens/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(LabelAdapter());

  await Hive.openBox("label");
  //Hive.box("label").add(Label("test"));
  // print(Hive.box("label").length);

  runApp(MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF424242),                    //Status bar color    0x121212 is much darker
      statusBarBrightness: Brightness.light,                //Status bar brightness
      statusBarIconBrightness:Brightness.light ,            //Status barIcon brightness
      systemNavigationBarColor: Color(0xFF424242),          //Navigation bar color
      systemNavigationBarDividerColor: Color(0xFF424242),   //Navigation bar divider color
      systemNavigationBarIconBrightness: Brightness.light,  //Navigation bar icon
    ));

    return FutureBuilder(
      future: Hive.openBox("note"),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          if(snapshot.hasError) return Text(snapshot.error.toString());
          else return MainPage();
        } else return Scaffold(
            backgroundColor: Color(0xFF424242),
            body: Center(child: CircularProgressIndicator())
        );
      }
    );
  }
}
