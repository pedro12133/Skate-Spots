import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

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
          child: Text('Sign Up',
            style: GoogleFonts.rockSalt(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              shadows:
              [Shadow(color: Colors.black,offset: Offset(-2.5, -2.5))],
            ), // Font
          ),
        ),
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
              SizedBox(height: 20),
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
                validator: (val) => val.length < 6  ? 'Enter a password with at least 6 characters' : null,
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
              SizedBox(height: 20),
              FloatingActionButton.extended(
                heroTag: "SignUp",
                backgroundColor: Colors.blueGrey,
                elevation: 5,
                label: Text(
                  "Sign Up",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if(_formKey.currentState.validate()) {
                    dynamic result = await _auth.registerWithEmail(email, password);
                    if(result == null)
                      setState(() => error = "Invalid email.");
                    else {
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
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
