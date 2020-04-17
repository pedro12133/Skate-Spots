import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skate_maps/auth.dart';
import 'package:skate_maps/register.dart';

import 'loading.dart';

class SignIn extends StatefulWidget {

  final Function setSignInStatus;
  SignIn({this.setSignInStatus});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = "";
  String password = "";
  String error = "";
  double screenHeight;
  double screenWidth;
  Color buttonColor = Colors.blueGrey;
  Color linkColor = Colors.white;

  Scaffold createSignInScaffold(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragStart: (details) => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.white, Colors.blueGrey],
            ),
          ),
          child: ListView(
            children: <Widget>[
              Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Opacity(
                            child: Image.asset(
                                'assets/images/icon.png',
                              height: 350,
                                width: 350,
                            ),
                            opacity: .3,
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            height: 300,
                            width: 350,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5, 200, 5, 0),
                                child: Text('Skate Spots',
                                  style: GoogleFonts.oleoScript(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ), // Font
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              validator: (val) => val.isEmpty ? 'Enter email' : null,
                              decoration: InputDecoration(
                                icon: Icon(Icons.email),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey, width: 1.0,)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blueGrey, width: 2.0,),
                                ),
                                border: OutlineInputBorder(),
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.grey[700]),

                              ),
                              onChanged: (val) {
                                setState(() => email = val);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              validator: (val) =>
                              val.length < 6
                                  ? 'Invalid password size.'
                                  : null,
                              decoration: InputDecoration(
                                icon: Icon(Icons.lock),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey, width: 1.0,)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blueGrey, width: 2.0,),
                                ),
                                border: OutlineInputBorder(),
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.grey[700]),

                              ),
                              obscureText: true,
                              onChanged: (val) {
                                setState(() => password = val);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                FloatingActionButton.extended(
                                  heroTag: "SignIn",
                                  backgroundColor: Colors.blueGrey,
                                  elevation: 5,
                                  label: Text(
                                    "Sign In",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      setState(() {
                                        loading = true;
                                      });
                                      dynamic result = await _auth.signInWithEmail(
                                          email, password);
                                      if (result == null)
                                        setState(() {
                                          error = "Invalid combination of email and password.";
                                          loading = false;
                                        });
                                      else {
                                        widget.setSignInStatus(true);
                                        Navigator.pop(context, true);
                                      }
                                    }
                                  },
                                ),
                                GestureDetector(
                                  child: Text(
                                    "Create Account",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: linkColor,
                                      decoration: TextDecoration.underline,),
                                  ),
                                  onTap: () async {
                                    var result = await Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => Register()));
                                    if(result != null && result)
                                      setState(() {
                                        widget.setSignInStatus(true);
                                        Navigator.pop(context);
                                      });
                                  },
                                  onLongPress: () {
                                    Color color;
                                    var rng = new Random();
                                    int choice = rng.nextInt(4);
                                    if(choice == 0)
                                      color = Colors.lightBlueAccent;
                                    if(choice == 1)
                                      color = Colors.lightGreenAccent;
                                    if(choice == 2)
                                      color = Colors.redAccent;
                                    if(choice == 3)
                                      color = Colors.white;
                                    setState((){linkColor = color;});
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),

                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),

                  SizedBox(height: 10),

                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

    @override
    Widget build(BuildContext context) {
      screenHeight = MediaQuery.of(context).size.height-100;
      screenWidth = MediaQuery.of(context).size.width;

      return loading ?
      Stack(
            children: <Widget>[
              createSignInScaffold(context),
              Loading()
            ],
      )
          :
      createSignInScaffold(context);

    }

}
