import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skate_maps/auth.dart';
import 'package:skate_maps/register.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";
  String error = "";


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
          child: Text('Sign In',
            style: GoogleFonts.rockSalt(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              shadows:
              [Shadow(color: Colors.black,offset: Offset(-2.5, -2.5))],
            ), // Font
          ),
        ),
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () async {
                var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
                if(result)
                  setState(() {
                    widget.toggleView();
                    Navigator.pop(context);
                  });
              },
              icon: Icon(Icons.person_add,color: Colors.white,),
              label: Text(
                "Sign Up",
                style: TextStyle(color: Colors.white),
              ),
          ),
        ],
      ),

      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Colors.white,Colors.blueGrey],
            ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(height: 10),
              TextFormField(
                validator: (val) => val.isEmpty ? 'Enter email' : null,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey,width: 2.0,)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey, width: 3.0,),
                  ),
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey[700]),

                ),
                onChanged: (val) { setState(() => email = val); },
              ),
              TextFormField(
                validator: (val) => val.length < 6  ? 'Invalid password size.' : null,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey,width: 2.0,)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey, width: 3.0,),
                  ),
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey[700]),

                ),
                obscureText: true,
                onChanged: (val) {setState(() => password = val);},
              ),
              SizedBox(height: 10),
              FloatingActionButton.extended(
                heroTag: "SignIn",
                backgroundColor: Colors.blueGrey,
                elevation: 5,
                label: Text(
                  "Sign In",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if(_formKey.currentState.validate()) {
                    dynamic result = await _auth.signInWithEmail(email, password);
                    if(result == null)
                      setState(() => error = "Invalid combination of email and password.");
                    else {
                      widget.toggleView();
                      Navigator.pop(context,true);
                    }
                  }
                },
              ),
              SizedBox(height: 10,),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
    }
}
