import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skate_maps/image_upload.dart';
import 'package:skate_maps/search_map.dart';
import 'package:skate_maps/skate_spot_info_page.dart';
import 'database.dart';
import 'auth.dart';
import 'package:provider/provider.dart';
import 'package:latlong/latlong.dart' as LatLong;
import 'loading.dart';

class Profile extends StatefulWidget {
  final Function setSignInStatus;
  Profile({this.setSignInStatus});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final AuthService _auth = AuthService();
  bool loading = false;
  String uid = "";
  String fname = "";
  String lname = "";
  String email = "";
  List<String> mySpots = [];
  List<String> favoriteSpots = [];
  String imageUrl = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png";


  double elevation = 10;
  double screenHeight;
  double screenWidth;
  Color cardColor = Colors.grey[200];
  Color cardIconColor = Colors.blueGrey;

  bool listToggled = false;
  String chosenList = "";
  List<Padding> infoCards = [];

  AuthService auth;
  DatabaseService db;

  @override
  void initState() {
    super.initState();
    auth = new AuthService();
  }

  @override
  Widget build(BuildContext context) {

    screenHeight = MediaQuery.of(context).size.height-100;
    screenWidth = MediaQuery.of(context).size.width;

    auth.getUser().then((onValue) {
      uid = onValue.uid;
      db = DatabaseService(uid:uid);
      db.usersCollection.document(uid).get().then((snap){
        try {
          setState(() {
            fname = snap.data['fname'];
            lname = snap.data['lname'];
            email = snap.data['email'];
            mySpots = List.from(snap.data['mySpots']);
            favoriteSpots = List.from(snap.data['favoriteSpots']);
            if(snap.data['img'] != null)
              imageUrl = snap.data['img'];
          });
        }
        catch(error) {
          // Exception Caught: Set state called but failed.
        }

      });
    }).catchError((onError){
      print(onError.toString());
    });

    return StreamProvider<QuerySnapshot>.value(
      value: DatabaseService().users,
      child: Scaffold(

        body:
          !loading ?
          bodyContainer()
              :
          Stack(
            children: <Widget>[
              bodyContainer(),
              Loading()],)
      ),
    );
  }

  Widget bodyContainer() {
    return Container(
      width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Colors.white,Colors.blueGrey],
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 30, 15, 10),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    child: Text('Profile',
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
                  FlatButton.icon(
                      icon: Icon(
                        Icons.exit_to_app,
                        color: Colors.blueGrey,
                      ),
                      label: Text(
                        "Sign Out",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _auth.signOut();
                        widget.setSignInStatus(false);
                      }
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width-20,
              height: MediaQuery.of(context).size.height-100,
              child: ListView(
                padding: EdgeInsets.all(20.0),
                children: <Widget>[
                  Card(
                    elevation: elevation,
                    color: cardColor,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                              height: screenHeight/3,
                              width: screenHeight/3,
                              decoration: new BoxDecoration(
                                  border: Border.all(width: 2, color: cardIconColor),
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: new NetworkImage(imageUrl),
                                  )
                              )
                          ),
                          PopupMenuButton<int>(
                            onSelected: (value) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => UploadImage(from: uid,to:"profile",amount: 1,)));
                            },
                            icon: Icon(Icons.more_horiz, color: cardIconColor,),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                child: Text("Edit"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: elevation,
                    color: cardColor,
                    child: ListTile(
                      leading: Icon(Icons.contacts, color: cardIconColor),
                      title: Text("$fname $lname",),
                      trailing: PopupMenuButton<int>(
                        onSelected: (value) {

                        },
                        icon: Icon(Icons.more_vert, color: cardIconColor,),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 1,
                            child: Text("Edit"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: elevation,
                    color: cardColor,
                    child: ListTile(
                      leading: Icon(Icons.email, color: cardIconColor),
                      title: Text(email, ),
                      trailing: PopupMenuButton<int>(
                        onSelected: (value) {

                        },
                        icon: Icon(Icons.more_vert, color: cardIconColor,),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 2,
                            child: Text("Edit"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: elevation,
                    color: cardColor,
                    child: ListTile(
                      leading: Icon(Icons.add_location, color: cardIconColor),
                      title: Text(mySpots.length.toString()),
                      trailing: PopupMenuButton<int>(
                        onSelected: (value)  {
                          setState(() {
                            listToggled = true;
                            chosenList = "My Spots";
                          });
                          setCards(value);

                        },
                        icon: Icon(Icons.more_vert, color: cardIconColor,),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 3,
                            child: Text("View"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: elevation,
                    color: cardColor,
                    child: ListTile(
                      leading: Icon(Icons.favorite, color: cardIconColor),
                      title: Text(favoriteSpots.length.toString()),
                      trailing: PopupMenuButton<int>(
                        onSelected: (value)  {
                          setState(() {
                            listToggled = true;
                            chosenList = "Favorite Spots";
                          });
                          setCards(value);
                        },
                        icon: Icon(Icons.more_vert, color: cardIconColor,),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 4,
                            child: Text("View"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  listToggled ?
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          chosenList,
                          style: GoogleFonts.oleoScript(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                      ),
                      Container(
                        decoration: new BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        width: MediaQuery.of(context).size.width - 20,
                        height: screenHeight/3,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: infoCards.length,
                          itemBuilder: (context, index) {return infoCards[index];},
                        ),
                      )
                    ],
                  )
                      :
                  Row(),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Future<void> setCards(int value)  async {
    setState(() => loading=true);
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    LatLong.Distance distance = new LatLong.Distance();

    setState(() => infoCards.clear());
    List<String> markerIds = [];
    if(value == 3)
      markerIds = mySpots;

    if(value == 4)
      markerIds = favoriteSpots;

    for(int i = 0; i < markerIds.length; i ++) {
      SkateSpot skateSpot = await db.getMarkerById(markerIds[i], i);

      List<Widget> icons = [];
      setState(() {
        for(Icon icon in skateSpot.coloredIcons)
          icons.add(
              Padding(
                padding: EdgeInsets.all(1),
                child: icon,
              )
          );
        infoCards.add(
          Padding(
            padding: const EdgeInsets.all(10),
            child: GestureDetector(
              onLongPress: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SkateSpotInfo(skateSpot)
                    )
                );
              },
              child: Card(
                elevation: elevation,
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        skateSpot.name,
                        style: GoogleFonts.rockSalt(
                          fontSize: 18,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: icons,
                      ),
                      Text(
                          skateSpot.distance.toStringAsFixed(2)+" miles"
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
    }
    setState(() => loading=false);
  }

}
