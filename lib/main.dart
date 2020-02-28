import 'package:flutter/material.dart';
import 'search_map.dart';
import 'map_menu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() => runApp(SkateMaps());

class SkateMaps extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SkateMaps();
  }
}

class _SkateMaps extends State<SkateMaps>{
  static String keyword = "Bakery";

  void updateKeyWord(String newKeyword) {
    print(newKeyword);
    setState(() {
      keyword = newKeyword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skate Maps',
      home: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                  icon: Icon(Icons.person),
                  tooltip: 'Search',
                  onPressed: () {

                  });
            },
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Colors.grey,Colors.blueGrey]
                )
            ),
          ),
          title: Center(
            child: Text('SkateMaps',
              style: GoogleFonts.rockSalt(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                shadows:
                [Shadow(color: Colors.black,offset: Offset(-2.5, -2.5))],
              ), // Font
            ),
          ),
          actions: <Widget>[
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                    icon: Icon(Icons.filter_list),
                    tooltip: 'Filter Search',
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    });
              },
            ),
          ],
        ),
        body: SearchMap(keyword),
        endDrawer: SearchFilter(updateKeyWord),
      ),
    );
  }
}
