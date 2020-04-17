import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skate_maps/auth.dart';
import 'package:skate_maps/popup_alert.dart';
import 'package:skate_maps/profile.dart';
import 'package:skate_maps/signIn.dart';
import 'package:skate_maps/user.dart';
import 'search_map.dart';
import 'map_menu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() => runApp(SkateMaps());

class SkateMaps extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SkateMaps();
  }
}

class _SkateMaps extends State<SkateMaps>{

  static const String _KEY_SELECTED_POSITIONS = "positions";
  static const String _KEY_SELECTED_RADIUS = "radius";
  static const String _KEY_SELECTED = "selected";

  bool signedIn = false;
  bool editingMarker = false;
  double radius = 5;
  List<String> keywords = [
    "Bank",
    "Gap",
    "Hill",
    "Ledge",
    "Rail",
    "Stairs",
    "Other"
  ];


  AuthService auth = new AuthService();

  @override
  void initState() {
    super.initState();
    _loadPreference();
    auth.getUser().then((onValue) {
      if(onValue != null)
        signedIn = true;
    }).catchError((onError){
      print(onError.toString());
    });
  }

  void _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if(prefs.getBool(_KEY_SELECTED) == null)
      setState(() {
        prefs.setStringList(_KEY_SELECTED_POSITIONS, ['1','1','1','1','1','1','1']);
        prefs.setInt(_KEY_SELECTED_RADIUS, 0);
      });
    else {
      List selectedPositions;
      setState(() {
        selectedPositions = prefs.getStringList(_KEY_SELECTED_POSITIONS);
        List<bool> isSelectedKeyword = [];
        List<String> filterOpts = [
          "Bank",
          "Gap",
          "Hill",
          "Ledge",
          "Rail",
          "Stairs",
          "Other"
        ];

        for(int i = 0; i < selectedPositions.length; i++)
          if(selectedPositions[i] == '1')
            isSelectedKeyword.add(true);
          else
            isSelectedKeyword.add(false);

        updateKeyWord(
            prefs.getInt(_KEY_SELECTED_RADIUS),
            filterOpts,
            isSelectedKeyword
        );
      });
    }
  }

  void setSignInStatus(bool status) {
    setState(() => signedIn = status);
  }

  void setMarkerEditSignInStatus(bool status) {
    setState(() => editingMarker = status);
  }

  void toggleMarkerEdit() {
    setState(() => editingMarker = !editingMarker);
  }

  void updateKeyWord(int rad, List<String> keywords, List<bool> selected) {
    setState(() {
      this.keywords.clear();
      for(int i = 0; i < keywords.length; i++)
        if(selected[i])
          this.keywords.add(keywords[i]);
      if(rad == 0)
        radius = 5;
      else if(rad == 1)
        radius = 10;
      else
        radius = 25;
  });
  }

  @override
  Widget build(BuildContext context) {

    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Skate Maps',
        home: Scaffold(
          appBar: AppBar(
            elevation: 10,
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                    icon: Icon(Icons.person),
                    tooltip: 'Search',
                    onPressed: () async {
                      var result;
                      if(!signedIn)
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn(setSignInStatus: setSignInStatus)));
                      else if (signedIn && !editingMarker)
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(setSignInStatus: setSignInStatus)));
                      else
                        showDialog(
                            context: context,
                          builder: (context) {
                              return PopupAlert('Set marker attributes or delete it.');
                          }
                        );
                    });
              },
            ),
            flexibleSpace: Container(
                color: Colors.blueGrey,
            ),
            title: Center(
              child: Text('Skate Spots',
                style: GoogleFonts.oleoScript(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ), // Font
              ),
            ),
            actions: <Widget>[
              Builder(
                builder: (BuildContext context) {
                  return IconButton(
                      icon: Icon(Icons.filter_list),
                      tooltip: 'Filter Search',
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      });
                },
              ),
            ],
          ),
          body: SearchMap(keywords,radius,signedIn,setMarkerEditSignInStatus),
          endDrawer: SearchFilter(updateKeyWord),
        ),
      ),
    );
  }
}
