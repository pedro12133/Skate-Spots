import "package:flutter/material.dart";
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
    "Park",
    "Street",
    "All",
  ];

  static const String _KEY_SELECTED_POSITION = "position";
  static const String _KEY_SELECTED_VALUE = "value";
  static const String _KEY_SELECTED_RADIUS = "radius";

  int _selectedPosition = 0;
  final Function updateKeyword;
  List<bool> isSelected = [false,true,false];
  int radius = 1;

  _SearchFilter(this.updateKeyword);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
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
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
            },
          ),
          title: Text('Filters',
            style: GoogleFonts.rockSalt(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              shadows:
              [Shadow(color: Colors.black,offset: Offset(-2.5, -2.5))],
            ), // Font
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
          child: ListView(
            children: <Widget>[
              SizedBox(height: 20),
              ListTile(
                selected: _selectedPosition == 0,
                leading: Image.asset("assets/images/park.png",),
                title: Text(filterOptions[0]),
                onTap: () {
                  _saveKeywordPreference(0);
                },
                trailing: _getIcon(0),
              ),
              SizedBox(height: 20),
              ListTile(
                selected: _selectedPosition == 1,
                leading: Image.asset("assets/images/street.png",),
                title: Text(filterOptions[1]),
                onTap: () {
                  _saveKeywordPreference(1);
                },
                trailing: _getIcon(1),
              ),
              SizedBox(height: 20),
              ListTile(
                selected: _selectedPosition == 2,
                leading: Image.asset("assets/images/xboards.jpg",),
                title: Text(filterOptions[2]),
                onTap: () {
                  _saveKeywordPreference(2);
                },
                trailing: _getIcon(2),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
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
                    isSelected: isSelected,
                    onPressed: (int index) async {
                      if(isSelected[index])
                        return;
                      setState(() {
                        for(int i = 0; i < isSelected.length; i++)
                          isSelected[i] = false;
                        isSelected[index] = true;
                        radius = index;
                        _saveKeywordPreference(_selectedPosition);
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        )
      ),
    );
  }

  Widget _getIcon(int value) {
    return Builder(
      builder: (BuildContext context) {
        if (value == _selectedPosition) {
          return Icon(Icons.check);
        } else {
          return SizedBox(
            width: 50,
          );
        }
      },
    );
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPosition = prefs.getInt(_KEY_SELECTED_POSITION) ?? 0;
      radius = prefs.getInt(_KEY_SELECTED_RADIUS);
      for(int i = 0; i < isSelected.length; i++)
        isSelected[i] = false;
      isSelected[radius] = true;

      print("======LOAD====> $radius");
    });
  }

  void _saveKeywordPreference(int position) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPosition = position;
      prefs.setString(_KEY_SELECTED_VALUE, filterOptions[position]);
      prefs.setInt(_KEY_SELECTED_POSITION, position);
      prefs.setInt(_KEY_SELECTED_RADIUS, radius);
      updateKeyword(filterOptions[position]+" $radius");
    });
  }
}
