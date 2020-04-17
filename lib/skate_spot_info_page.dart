import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skate_maps/database.dart';
import 'package:skate_maps/search_map.dart';
import 'auth.dart';

class SkateSpotInfo extends StatefulWidget {
  final SkateSpot skateSpot;

  SkateSpotInfo(this.skateSpot);

  @override
  _SkateSpotInfoState createState() => _SkateSpotInfoState();
}

class _SkateSpotInfoState extends State<SkateSpotInfo> {

  double screenHeight;
  double screenWidth;
  List<String> imageURLs = [];
  List<Widget> images = [];
  AuthService auth = new AuthService();
  DatabaseService db;
  bool loggedIn = false;
  GoogleMapController _mapController;
  LatLng coordinates;
  Marker marker;
  bool isFavorite = false;

  @override
  void initState()  {
    super.initState();
    setState(() => coordinates = LatLng(widget.skateSpot.lat,widget.skateSpot.lon));

    auth.getUser().then((onValue) {
      if(onValue != null) {
        setState(() => loggedIn = true);
        db = new DatabaseService(uid: onValue.uid);
        db.usersCollection.document(onValue.uid).get().then((snap) {
          if(List.from(snap.data['favoriteSpots']).contains(widget.skateSpot.id))
            setState(() => isFavorite = true);
        });
      }
      setIcon();
    }).catchError((onError){});
  }

  setIcon() async {

    BitmapDescriptor pinLocationIcon;
    await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 1), 'assets/images/marker.png')
        .then((icon) {
      setState(() {
        pinLocationIcon = icon;
      });
    });

    setState(() {
      marker = Marker(
        icon: pinLocationIcon,
        markerId: MarkerId("id"),
        position: coordinates,
        infoWindow: InfoWindow(title:widget.skateSpot.name),
      );
    });

  }


  // camera methods
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  List<Widget> getCategories() {
    List<Widget> categories = [];
    List keywords = widget.skateSpot.categories.toString().split(' ');
    int count = 0;
    for(Icon icon in widget.skateSpot.coloredIcons) {
      categories.add(
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: <Widget>[
              Text(keywords[count], style: TextStyle(fontWeight: FontWeight.bold),),
              icon,
            ],
          ),
        )
      );
      count++;
    }
    return categories;
  }

  void getImages()   {
    images.clear();
    setState(() => imageURLs = widget.skateSpot.imageURLs);
    setState(() {
      for (int i = 0; i < imageURLs.length; i++) {
        images.add(
          Padding(
            padding: const EdgeInsets.all(5),
            child: Card(
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Image.network(imageURLs[i]),
              ),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    screenHeight = MediaQuery.of(context).size.height-100;
    screenWidth = MediaQuery.of(context).size.width;
    getImages();
    return Scaffold(
      body: Container(
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
            Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      child: Text(widget.skateSpot.name,
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
                      icon: Icon(Icons.favorite,color: isFavorite ? Colors.pink[300] : Colors.white,),
                      onPressed: () {
                        // add to favorite spots
                        db.updateUserFavoriteMarkers(widget.skateSpot.id);
                        setState(() => isFavorite = !isFavorite);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                height: MediaQuery.of(context).size.height-100,
                child: ListView(
                  children: <Widget>[
                    images.length > 0?
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
                          child: Text(
                            "Images",
                            textAlign: TextAlign.center,
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
                          height: screenHeight/2.5,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: images,
                          ),
                        )
                      ],
                    )
                    :
                    Row(),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "Description",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.oleoScript(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[700],
                                ),
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: widget.skateSpot.description,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.all(6),),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "Features",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.oleoScript(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: getCategories(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        height: screenWidth/1.5,
                        width: screenWidth,
                        child: GoogleMap(
                            markers: Set.from([marker]),
                            myLocationEnabled: true,
                            mapType: MapType.normal,
                            initialCameraPosition: CameraPosition(
                              target: coordinates,
                              zoom: 15,
                              bearing: 0.0,
                              tilt: 17,
                            ),
                            onMapCreated: (controller) {
                              _onMapCreated(controller);
                            }
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
