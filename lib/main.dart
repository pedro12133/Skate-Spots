import 'package:flutter/material.dart';
import 'package:skate_maps/auth.dart';
import 'package:skate_maps/profile.dart';
import 'package:skate_maps/signIn.dart';
import 'package:skate_maps/user.dart';
import 'search_map.dart';
import 'map_menu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() => runApp(SkateMaps());

class SkateMaps extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SkateMaps();
  }
}

class _SkateMaps extends State<SkateMaps>{
  static String keyword = "All";
  bool signedIn = false;

  void toggleView() {
    setState(() => signedIn = !signedIn);
  }

  void updateKeyWord(String newKeyword) {
    setState(() {
      keyword = newKeyword;
    });
  }

  @override
  Widget build(BuildContext context) {

    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Skate Maps',
        home: Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                    icon: Icon(Icons.person),
                    tooltip: 'Search',
                    onPressed: () async {
                      var result;
                      if(!signedIn)
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn(toggleView: toggleView)));
                      else
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(toggleView: toggleView)));

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
      ),
    );
  }
}
