import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PopupAlert extends StatelessWidget {

  final text;
  PopupAlert(this.text);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      elevation: 20,
      backgroundColor: Colors.grey,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            new BoxShadow(
              color: Colors.black12,
              offset: new Offset(10.0, 10.0),
            )
          ],
          borderRadius: BorderRadius.all(Radius.circular(10)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Colors.white,Colors.blueGrey],
          ),
        ),
        height: 200.0,
        width: 300.0,
        child: Center(
          child: Column(
            children: <Widget>[

              SizedBox(height: 20),

              Text('Attention!',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),

              SizedBox(height: 20),

              Text(text),

              SizedBox(height: 20),

              FloatingActionButton.extended(
                backgroundColor: Colors.blueGrey[700],
                elevation: 0,
                icon: Icon(Icons.thumb_up),
                label: Text(
                  "OK",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}