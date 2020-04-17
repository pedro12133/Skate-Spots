import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchFilter extends StatefulWidget {
  final Function updateKeyword;

  SearchFilter(this.updateKeyword);

  @override
  State<StatefulWidget> createState() {
    return _SearchFilter(updateKeyword);
  }
}

class _SearchFilter extends State<SearchFilter> {
  static final List<String> filterOptions = <String>[
    "Bank",
    "Gap",
    "Hill",
    "Ledge",
    "Rail",
    "Stairs",
    "Other"
  ];

  static const String _KEY_SELECTED_POSITIONS = "positions";
  static const String _KEY_SELECTED_RADIUS = "radius";
  static const String _KEY_SELECTED = "selected";

  final Function updateKeyword;
  List<bool> isSelectedRadius = [false,false,false];
  List<bool> isSelectedKeyword = [false,false,false,false,false,false,false];
  TextStyle selectedStyle = TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold);
  TextStyle unselectedStyle = TextStyle(color: Colors.black);
  Icon selectedIcon = Icon(Icons.check,color: Colors.lightBlue);
  Column unselectedIcon = Column();
  int radiusPosition = 0;
  Color boxBorderColor = Colors.black;


  double screenHeight;
  double screenWidth;

  _SearchFilter(this.updateKeyword);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height-100;
    return Drawer(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Colors.white,Colors.blueGrey]
            ),
          ),
          child: _getFilterList()
        )
      ),
    );
  }

  List _getListTiles() {
    List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow[600],
      Colors.green,
      Colors.blue[400],
      Colors.blue[800],
      Colors.purple
    ];
    List<Widget> tiles = [
      Center(
        child: Text('Filters',
          style: GoogleFonts.oleoScript(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            decoration: TextDecoration.underline,
          ), // Font
        ),
      ),
    ];
    setState(() {
      for(int i = 0; i < filterOptions.length; i++)
        tiles.add(Padding(
          padding: const EdgeInsets.all(4.0),
          child: ListTile(
            leading: Container(
              decoration: isSelectedKeyword[i] ? BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(width: 1, color:  Colors.lightBlue )
              )
              :
              BoxDecoration(),
              height: 62,
                width: 62,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                            "assets/images/"+i.toString()+".png",
                          height: 30,
                          width: 30,
                        ),
                        Icon(Icons.location_on,color: colors[i],)
                      ]
                  ),
                ),
            ) ,
            title: Text(
              filterOptions[i],
              style: isSelectedKeyword[i] ? selectedStyle : unselectedStyle,
            ),
            onTap: () {
              setState(() {
                isSelectedKeyword[i] = !isSelectedKeyword[i];
              });
              _savePreference();
            },
            trailing: isSelectedKeyword[i] ? selectedIcon : unselectedIcon,
          ),
        ));

      tiles.add(Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: FloatingActionButton.extended(
                elevation: 0,
                backgroundColor: Colors.blueGrey,
                icon: Icon(Icons.select_all),
                heroTag: "All",
                  onPressed: (){
                    setState(() {
                      for(int i = 0; i < isSelectedKeyword.length; i++)
                        isSelectedKeyword[i] = true;
                    });
                    _savePreference();
                  },
                  label: Text(" All ")

              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FloatingActionButton.extended(
                  elevation: 0,
                  backgroundColor: Colors.blueGrey,
                  icon: Icon(Icons.clear),
                  heroTag: "Clear",
                  onPressed: (){
                    setState(() {
                      for(int i = 0; i < isSelectedKeyword.length; i++)
                        isSelectedKeyword[i] = false;
                    });
                    _savePreference();
                  },
                  label: Text("Clear")
              ),
            ),
          ],
        )
      ));
      tiles.add(
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ToggleButtons(
                borderColor: Colors.blueGrey,
                color: Colors.grey[700],
                fillColor: Colors.blueGrey,
                selectedColor: Colors.white,
                selectedBorderColor: Colors.grey,
                borderRadius: BorderRadius.circular(30),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20),
                      Text(" 5 mi",style: TextStyle(fontSize: 20)),
                      SizedBox(width: 20),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20),
                      Text("10 mi",style: TextStyle(fontSize: 20)),
                      SizedBox(width: 20),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20),
                      Text("25 mi",style: TextStyle(fontSize: 20)),
                      SizedBox(width: 20),
                    ],
                  ),
                ],
                isSelected: isSelectedRadius,
                onPressed: (int index) async {
                  if(isSelectedRadius[index])
                    return;
                  setState(() {
                    for(int i = 0; i < isSelectedRadius.length; i++)
                      isSelectedRadius[i] = false;
                    isSelectedRadius[index] = true;
                    radiusPosition = index;
                    _savePreference();
                  });
                },
              ),
            ],
          ),
        ),
      );
    });
    return tiles;
  }

  Padding _getFilterList() {
    return Padding(
      padding: EdgeInsets.all(5),
      child: ListView(
        children: _getListTiles(),
      ),
    );
  }
  

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List selectedPositions;
    setState(() {
      selectedPositions = prefs.getStringList(_KEY_SELECTED_POSITIONS) ?? ['1','1','1','1','1','1','1'];
      radiusPosition = prefs.getInt(_KEY_SELECTED_RADIUS) ?? 0;
      isSelectedRadius[radiusPosition] = true;
      for(int i = 0; i < selectedPositions.length; i++)
        if(selectedPositions[i] == '1')
          isSelectedKeyword[i] = true;
        else
          isSelectedKeyword[i] = false;
    });
  }

  void _savePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {

      List<String> selectedPositions = [];
      for(int i = 0; i < isSelectedKeyword.length; i++)
        if(isSelectedKeyword[i])
          selectedPositions.add('1');
        else
          selectedPositions.add('0');

      prefs.setBool(_KEY_SELECTED, true);
      prefs.setStringList(_KEY_SELECTED_POSITIONS, selectedPositions);
      prefs.setInt(_KEY_SELECTED_RADIUS, radiusPosition);
      updateKeyword(radiusPosition,filterOptions,isSelectedKeyword);
    });
  }
}
