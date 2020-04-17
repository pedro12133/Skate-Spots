import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'loading.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = "";
  String password = "";
  String error = "";
  String fname = "";
  String lname = "";
  double screenHeight;
  double screenWidth;
  Color buttonColor = Colors.blueGrey;
  Color linkColor = Colors.white;

  Scaffold createSignOutScaffold(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragStart: (details) => Navigator.pop(context),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.white,Colors.blueGrey],
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
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                validator: (val) => val.isEmpty ? 'Enter first name' : null,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.person_pin),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blueGrey,width: 1.0,)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blueGrey, width: 2.0,),
                                  ),
                                  border: OutlineInputBorder(),
                                  labelText: 'First Name',
                                  labelStyle: TextStyle(color: Colors.grey[700]),
                                ),
                                onChanged: (val) { setState(() => fname = val); },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                validator: (val) => val.isEmpty ? 'Enter last name' : null,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.person_pin),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blueGrey,width: 1.0,)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blueGrey, width: 2.0,),
                                  ),
                                  border: OutlineInputBorder(),
                                  labelText: 'Last Name',
                                  labelStyle: TextStyle(color: Colors.grey[700]),

                                ),
                                onChanged: (val) { setState(() => lname = val); },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                validator: (val) => val.isEmpty ? 'Enter email' : null,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.email),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blueGrey,width: 1.0,)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blueGrey, width: 2.0,),
                                  ),
                                  border: OutlineInputBorder(),
                                  labelText: 'Email',
                                  labelStyle: TextStyle(color: Colors.grey[700]),

                                ),
                                onChanged: (val) { setState(() => email = val); },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                validator: (val) => val.length < 6  ? 'Enter a password with at least 6 characters' : null,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.lock),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blueGrey,width: 1.0,)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blueGrey, width: 2.0,),
                                  ),
                                  border: OutlineInputBorder(),
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: Colors.grey[700]),

                                ),
                                obscureText: true,
                                onChanged: (val) {setState(() => password = val);},
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: FloatingActionButton.extended(
                                    heroTag: "SignUp",
                                    backgroundColor: Colors.blueGrey,
                                    elevation: 5,
                                    label: Text(
                                      "Sign Up",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      if(_formKey.currentState.validate()) {
                                        setState(() => loading = true);
                                        dynamic result = await _auth.registerWithEmail(email, password,fname,lname);
                                        if(result == null)
                                          setState(() {
                                            error = "Invalid email.";
                                            loading = false;
                                          });
                                        else {
                                          Navigator.pop(context,true);
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
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
        createSignOutScaffold(context),
        Loading()
      ],
    )
        :
    createSignOutScaffold(context);

  }
}
