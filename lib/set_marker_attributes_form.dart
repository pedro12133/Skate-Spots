import 'dart:io';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'database.dart';
import 'loading.dart';




class AttributesForm extends StatefulWidget {

  String from;
  double lat;
  double lon;

  AttributesForm({this.from,this.lat,this.lon});

  @override
  State<StatefulWidget> createState() {
    return _AttributesForm();
  }
}

class _AttributesForm extends State<AttributesForm>{

  final nameFieldController = new TextEditingController();
  final descriptionFieldController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<String> categories0 = ["Stairs","Gap","Rail","Ledge"];
  List<String> categories1 = ["Hill","Bank","Other"];
  List<bool> isSelected0 = [false,false,false,false];
  List<bool> isSelected1 = [false,false,false];

  int selectionCount = 0;
  String chosenCategories = "";
  String categorySelectionError = "";
  String descriptionError = "";

  Color categoryBoarderColor = Colors.blueGrey;
  Color buttonColor = Colors.blueGrey;
  Color cardIconColor = Colors.blueGrey;
  Color cardColor = Colors.grey[200];

  double screenHeight;
  double screenWidth;
  String name = "";
  String description = "";
  double lat;
  double lon;
  int amount = 3;
  bool loading = false;
  List<File> images  = [];
  List<Widget> cards = [];

  DatabaseService database;

  @override
  void initState(){
    super.initState();
    database = DatabaseService(uid: widget.from);
    lat = widget.lat;
    lon = widget.lon;
  }



  @override
  Widget build(BuildContext context) {

    screenHeight = MediaQuery.of(context).size.height-100;
    screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
        /*appBar: AppBar(
          elevation: 10,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent[100],),
              onPressed: () {
              Navigator.pop(this.context,["Delete"]);
              }
              );
            },
          ),
          flexibleSpace: Container(
            color: Colors.blueGrey,
          ),
          title: Center(
            child: Text('Attributes',
              style: TextStyle(
                fontSize: 25,
              ),
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add_location, color: Colors.greenAccent[100],),
              onPressed: () async {

                if(_formKey.currentState.validate() &&
                    selectionCount > 0 &&
                    descriptionFieldController.text.isNotEmpty) {
                  setState(() => loading = true);

                  name = nameFieldController.text;
                  description = descriptionFieldController.text;

                  for(int i = 0; i < isSelected0.length; i++)
                    if(isSelected0[i])
                      chosenCategories += categories0[i]+" ";

                  for(int i = 0; i < isSelected1.length; i++)
                    if(isSelected1[i])
                      chosenCategories += categories1[i]+" ";
                    await uploadFile();
                }
                else {

                  if(selectionCount < 1)
                    setState(() {
                      categorySelectionError = "Choose at least one category";
                      categoryBoarderColor = Colors.red[700];
                    });
                  else
                    setState(() {
                      categorySelectionError = "";
                      categoryBoarderColor = Colors.blueGrey;
                    });

                  if(descriptionFieldController.text.isEmpty)
                    setState(() {
                      descriptionError = "Enter a description";
                    });
                  else
                    setState(() {
                      descriptionError = "";
                    });
                }
              },
            ),
          ],
        ),*/
        body: !loading ?
        bodyContainer()
            :
            Stack(
              children: <Widget>[
                bodyContainer(),
                Loading(),
              ],
            )
      ),
    );
  }

  Container bodyContainer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Colors.white,Colors.blueGrey]
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 30, 15, 10),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    child: Text('Set Attributes',
                      style: GoogleFonts.oleoScript(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                        decoration: TextDecoration.underline,
                      ), // Font
                    ),
                    onHorizontalDragEnd: (detail) => Navigator.pop(context),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.pop(this.context,["Delete"]);
                    }
                  ),
                  IconButton(
                    icon: Icon(Icons.add_location, color: Colors.green,),
                    onPressed: () async {

                      if(_formKey.currentState.validate() &&
                          selectionCount > 0 &&
                          descriptionFieldController.text.isNotEmpty) {
                        setState(() => loading = true);

                        name = nameFieldController.text;
                        description = descriptionFieldController.text;

                        for(int i = 0; i < isSelected0.length; i++)
                          if(isSelected0[i])
                            chosenCategories += categories0[i]+" ";

                        for(int i = 0; i < isSelected1.length; i++)
                          if(isSelected1[i])
                            chosenCategories += categories1[i]+" ";
                        await uploadFile();
                      }
                      else {

                        if(selectionCount < 1)
                          setState(() {
                            categorySelectionError = "Choose at least one category";
                            categoryBoarderColor = Colors.red[700];
                          });
                        else
                          setState(() {
                            categorySelectionError = "";
                            categoryBoarderColor = Colors.blueGrey;
                          });

                        if(descriptionFieldController.text.isEmpty)
                          setState(() {
                            descriptionError = "Enter a description";
                          });
                        else
                          setState(() {
                            descriptionError = "";
                          });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              height: MediaQuery.of(context).size.height-100,
              child: ListView(
                children: <Widget>[
                  Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        maxLength: 20,
                        maxLengthEnforced: true,
                        validator: (val) => val.isEmpty ? 'Enter a name' : null,
                        controller: nameFieldController,
                        decoration: InputDecoration(
                          fillColor: Colors.white12,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueGrey,width: 1.0,)
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey, width: 2.0,),
                          ),
                          border: OutlineInputBorder(),
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Colors.grey[700]),

                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Features",
                              style: GoogleFonts.oleoScript(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          ToggleButtons(
                            borderColor: categoryBoarderColor,
                            color: Colors.grey[700],
                            fillColor: Colors.blueGrey,
                            selectedColor: Colors.white,
                            selectedBorderColor: Colors.grey,
                            borderRadius: BorderRadius.circular(30),
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(screenWidth/30),
                                child: Text("Stairs",style: TextStyle(fontSize: 20)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(screenWidth/30),
                                child: Text("Gap",style: TextStyle(fontSize: 20)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(screenWidth/30),
                                child: Text("Rail",style: TextStyle(fontSize: 20)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(screenWidth/30),
                                child: Text("Ledge",style: TextStyle(fontSize: 20)),
                              ),
                            ],
                            isSelected: isSelected0,
                            onPressed: (int index) {
                              setState(() {
                                if(isSelected0[index])
                                  selectionCount--;
                                else
                                  selectionCount++;
                                isSelected0[index] = !isSelected0[index];
                              });
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.all(screenWidth/50),
                            child: ToggleButtons(
                              borderColor: categoryBoarderColor,
                              color: Colors.grey[700],
                              fillColor: Colors.blueGrey,
                              selectedColor: Colors.white,
                              selectedBorderColor: Colors.grey,
                              borderRadius: BorderRadius.circular(30),
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(screenWidth/30),
                                  child: Text("  Hill  ",style: TextStyle(fontSize: 20)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(screenWidth/30),
                                  child: Text("Bank",style: TextStyle(fontSize: 20)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(screenWidth/30),
                                  child: Text("Other",style: TextStyle(fontSize: 20)),
                                ),
                              ],
                              isSelected: isSelected1,
                              onPressed: (int index) {
                                setState(() {
                                  if(isSelected1[index])
                                    selectionCount--;
                                  else
                                    selectionCount++;
                                  isSelected1[index] = !isSelected1[index];
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(screenWidth/50),
                            child: Text(categorySelectionError, style: TextStyle(color: Colors.red[700], fontSize: 12),),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                              Text(
                                "Description",
                                style: GoogleFonts.oleoScript(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                              ),
                              width: MediaQuery.of(context).size.width - 20,
                              height: screenHeight/3.5,
                              child: TextField(
                                controller: descriptionFieldController,
                                maxLength: 250,
                                maxLengthEnforced: true,
                                maxLines: 12,
                                decoration: InputDecoration.collapsed(
                                    hintText: "Enter your description here",
                                  hintStyle: TextStyle(color: Colors.grey,fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(screenWidth/50),
                            child: Text(descriptionError, style: TextStyle(color: Colors.red[700], fontSize: 12),),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Images",
                              style: GoogleFonts.oleoScript(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: screenWidth,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: <Widget>[
                              Spacer(),
                              images.length < amount ?
                              IconButton(
                                icon: Icon(
                                  Icons.add_photo_alternate,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  name = nameFieldController.text;
                                  description = descriptionFieldController.text;
                                  chooseFile();
                                  nameFieldController.text = name;
                                  descriptionFieldController.text = description;
                                },
                              )
                                  :
                              Spacer(),

                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.vertical(bottom:Radius.circular(10)),
                        ),
                        width: MediaQuery.of(context).size.width - 20,
                        height: screenHeight/2,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(vertical:20,horizontal: 20),
                          children: cards.length > 0 ?
                          cards : [Text("View added images here",style: TextStyle(color: Colors.grey,fontSize: 14))] ,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future chooseFile() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      images.add(image);
    });
    generateCards();
  }

  void generateCards() {
    cards.clear();
    List<Widget> newCards = [];
    for(int i = 0; i < images.length; i++) {
      newCards.add(
        Padding(
          padding: EdgeInsets.all(5),
          child: Card(
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                    Image.file(
                        images[i],
                      height: 300,
                    ),
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      images.removeAt(i);
                      generateCards();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    setState(() {
      cards = newCards;
    });
  }

  Future uploadFile() async {
    try {
      // add spot to markers
      var result = await database.addMarker(chosenCategories, lat, lon, name, description);
      // add spot to user custom markers
      await database.updateUserMarkers(result.documentID);
      // add images to marker images
      if(images.length > 0)
        await database.updateMarkerImages(result.documentID,images);
    }
    catch(error) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
    setState(() => loading = false);
    Navigator.pop(context, true);
  }

}
