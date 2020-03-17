
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';


class AttributesForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AttributesForm();
  }
}

class _AttributesForm extends State<AttributesForm>{

  final textEditingController = new TextEditingController();
  List<bool> isSelected = [false,false,false,false];
  List<String> categories = ["Stairs","Gap","Rail","Ledge"];
  String chosenCategories = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attributes Form',
      home: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                  icon: Icon(Icons.clear),
                  tooltip: 'Search',
                  onPressed: () {
                    Navigator.pop(this.context);
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
            child: Text('Attributes',
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
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.white,Colors.blueGrey]
              ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(height: 20),
                ToggleButtons(
                  borderColor: Colors.blueGrey,
                  color: Colors.white,
                  fillColor: Colors.blueGrey,
                  selectedColor: Colors.white,
                  selectedBorderColor: Colors.grey,
                  borderRadius: BorderRadius.circular(30),
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(width: 20),
                        Text("Stairs",style: TextStyle(fontSize: 20)),
                        SizedBox(width: 20),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 20),
                        Text("Gap",style: TextStyle(fontSize: 20)),
                        SizedBox(width: 20),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 20),
                        Text("Rail",style: TextStyle(fontSize: 20)),
                        SizedBox(width: 20),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 20),
                        Text("Ledge",style: TextStyle(fontSize: 20)),
                        SizedBox(width: 20),
                      ],
                    ),
                  ],
                  isSelected: isSelected,
                  onPressed: (int index) {
                    int count = 0;
                    isSelected.forEach((bool val) {
                      if (val) count++;
                    });
                    if (isSelected[index] && count < 2)
                      return;
                    setState(() {
                      isSelected[index] = !isSelected[index];
                    });
                  },
                ),
                SizedBox(height: 20),
                Container(
                  width: 300,
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    controller: textEditingController,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey,width: 2.0,)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey, width: 3.0,),
                        ),
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.white),

                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                FloatingActionButton.extended(
                  heroTag: "Add",
                  backgroundColor: Colors.blueGrey,
                  elevation: 5,
                  label: Text(
                        "  Add  ",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        if(!textIsEmpty(textEditingController.text)) {
                          for(int i = 0; i < isSelected.length; i++)
                            if(isSelected[i])
                              chosenCategories += categories[i]+" ";
                          Navigator.pop(this.context,["Add",chosenCategories,textEditingController.text]);
                        }
                        else
                          ;
                      },
                    ),
                    FloatingActionButton.extended(
                      heroTag: "Delete",
                      backgroundColor: Colors.blueGrey,
                      elevation: 5,
                      label: Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        /*setState(() {
                          markers.clear();
                        });
                        editingMarker = false;*/
                        Navigator.pop(this.context,["Delete"]);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool textIsEmpty(String text) {
    if(text.replaceAll(" ", "").length > 0)
      return false;
    return true;
  }
}
