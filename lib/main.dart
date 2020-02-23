import 'package:flutter/material.dart';
import 'search_map.dart';
import 'map_menu.dart';
import 'package:google_fonts/google_fonts.dart';

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
                  icon: Icon(Icons.add_location),
                  tooltip: 'Search',
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
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
                    icon: Icon(Icons.menu),
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

//Row(
//mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//children: <Widget>[
//BottomNavigationBarItem(
//icon: Icon(Icons.home, size: 40, color: Colors.white),
//),
//FloatingActionButton(
//child: Icon(Icons.map, size: 40, color: Colors.white),
//backgroundColor: Colors.blueGrey,
//),
//FloatingActionButton(
//child: Icon(Icons.person, size: 40, color: Colors.white),
//backgroundColor: Colors.blueGrey,
//),
//],
//),