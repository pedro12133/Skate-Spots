import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth.dart';

class Profile extends StatefulWidget {
  final Function toggleView;
  Profile({this.toggleView});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          child: Text('Profile',
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
              return FlatButton.icon(
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _auth.signOut();
                    widget.toggleView();
                    Navigator.pop(context);
                  }
              );
            },
          ),
        ],
      ),

      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.white,Colors.blueGrey],
            ),
          ),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(),

              ],
            ),
          )
      ),
    );
  }
}
