
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skate_maps/set_marker_attributes_form.dart';
import 'package:skate_maps/user.dart';
import 'data/error.dart';
import 'data/place_response.dart';
import 'data/result.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong/latlong.dart' as LatLong;


class SearchMap extends StatefulWidget {
  final String keyword;
  SearchMap(this.keyword);

  @override
  State<SearchMap> createState() {
    return _SearchMap();
  }
}

class _SearchMap extends State<SearchMap> {
  static const String _API_KEY = '';
  double lat = 34.1314283;
  double lon = -118.06987;
  static double tilt = 75;
  static double zoom = 12;
  static const String baseUrl =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json";
  final databaseRef = Firestore.instance;
  List<Marker> markers = [];
  Error error;
  List<Result> places;
  bool searching = true;
  String keyword;
  int locationCount = 0;
  GoogleMapController _mapController;
  bool editingMarker = false;
  GeoPoint editMarkerPosition;
  LatLng cameraPosition;

  @override
  void initState(){
    super.initState();

  }

  static final CameraPosition _myLocation = CameraPosition(
      target: LatLng(34.0551, -117.7500),
      zoom: zoom,
      bearing: 0.0,
      tilt: tilt,
  );

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    bool _userIsSignedIn() {
      if(user != null)
        return true;
      return false;
    }

    return Scaffold(
      body: GoogleMap(
        onCameraMove: (position) {
          setState(() {
            cameraPosition = position.target;
          });
        },
        myLocationEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: _myLocation,
        onMapCreated: (GoogleMapController controller) {
          _onMapCreated(controller);
          _panToCurrentLocation(controller);
        },
        markers: Set.from(markers),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 10,
        onPressed: () {
          if(!editingMarker) {
            search();
            _mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                    CameraPosition(
                      zoom: 11.5,
                      tilt: tilt,
                      target: LatLng(cameraPosition.latitude, cameraPosition.longitude),
                    )
                )
            );
          }
          else {
            _mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                    CameraPosition(
                      zoom: zoom,
                      tilt: tilt,
                      target: LatLng(editMarkerPosition.latitude, editMarkerPosition.longitude),
                    )
                )
            );
            popupMessage("Attributes for current marker aren\'t set.");
          }
        },
        backgroundColor: Colors.grey,
        child: Image.asset("assets/images/skate.png"),
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:  BottomAppBar(
        color: Colors.blueGrey,
        shape: CircularNotchedRectangle(),
        notchMargin: 1.5,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          height: 56.0,
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  if(!editingMarker) {
                    //showMenu();
                  }
                  else{
                    _mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                            CameraPosition(
                              zoom: zoom,
                              tilt: tilt,
                              target: LatLng(editMarkerPosition.latitude, editMarkerPosition.longitude),
                            )
                        )
                    );
                    popupMessage("Attributes for current marker aren\'t set.");
                  }
                },
                icon: Icon(Icons.list),
                color: Colors.white,
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  if(_userIsSignedIn()) {
                    if(!editingMarker)
                      _addMarker();
                    else {
                      _mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                              CameraPosition(
                                zoom: zoom,
                                tilt: tilt,
                                target: LatLng(
                                    editMarkerPosition.latitude,
                                    editMarkerPosition.longitude
                                ),
                              )
                          )
                      );
                      popupMessage("Attributes for current marker aren\'t set.");
                    }
                  }
                  else
                    popupMessage("You need to sign in to use this feature.");
                },
                icon: Icon(Icons.add_location),
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getSavedSpots(double radius) {

    LatLong.LatLng userLatLng = new LatLong.LatLng(cameraPosition.latitude, cameraPosition.longitude);
    final LatLong.Distance distance = new LatLong.Distance();

    BitmapDescriptor pinLocationIcon;
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 0.5), 'assets/images/marker.png')
      .then((icon) {
        setState(() {
          pinLocationIcon = icon;
        });
    });

    markers.clear();

    var docs = [];
    var snaps = databaseRef
        .collection('markers')
        .getDocuments()
        .then((snapshot) {



      for(var x in snapshot.documents) {

        LatLong.LatLng markerLatLng = new LatLong.LatLng(x['lat'], x['lon']);
        double meters = distance(userLatLng, markerLatLng);

        if(meters <= radius) {
          print("distance: $meters name: "+x['name']);
          setState(() {
            final marker = Marker(
              icon: pinLocationIcon,
              markerId: MarkerId(x['name']),
              position: LatLng(x['lat'], x['lon']),
              infoWindow: InfoWindow(
                  title: x['name'],
                  snippet: x['category']),
              onTap: () {
                //not sure
              },
            );
            markers.add(marker);
            print("len ======> "+markers.length.toString());
          });
        }
        else
          print("No data!");
      }
    });
  }

  void _saveSpot(String category, String label, double lat, double lon) async {
    try {
      await databaseRef.collection('markers')
          .add({
        'category' : category,
        'lat': lat,
        'lon': lon,
        'name' : label
      });
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Skate spot added.")));
    }
    catch(error) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Error: "+error.toString())));
    }

  }

  void _addMarker() async {

    markers.clear();

    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    GeoPoint coordinates = new GeoPoint(
        currentLocation.latitude,
        currentLocation.longitude
    );
    editMarkerPosition = new GeoPoint(cameraPosition.latitude, cameraPosition.longitude);
    String label = "";
    String category = "";
    editingMarker = true;

    setState(() {
      final marker = Marker(
        draggable: true,
        onDragEnd: (value) {
          coordinates = new GeoPoint(value.latitude, value.longitude);
          editMarkerPosition = coordinates;
        },
        markerId: MarkerId(locationCount.toString()),
        position: LatLng(cameraPosition.latitude, cameraPosition.longitude),
        onTap: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AttributesForm()));

          if(result[0] == "Delete") {
            editingMarker = false;
            setState(() {
              markers.clear();
            });
          }

          if(result[0] == "Add") {
            category = result[1];
            label = result[2];
            _saveSpot(category, label, coordinates.latitude, coordinates.longitude);
            editingMarker = false;
            setState(() {
              markers.clear();
            });
          }
          },
      );
      markers.add(marker);

    });

  }

  void popupMessage(String text) {
    showDialog(
      context: context,
      builder: (context) {
        return new Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          elevation: 16,
          backgroundColor: Colors.grey,
          child: Container(
            decoration: BoxDecoration(
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
                    style: GoogleFonts.rockSalt(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows:
                      [Shadow(color: Colors.black,offset: Offset(-2.5, -2.5))],
                    ), // Font
                  ),

                  SizedBox(height: 20),

                  Text(text),

                  SizedBox(height: 20),

                  RaisedButton(
                    color: Colors.blueGrey,
                    elevation: 5,
                    child: Text(
                      "OK",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      //close popup
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _panToCurrentLocation(GoogleMapController controller) async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(currentLocation.latitude,currentLocation.longitude),
              zoom: zoom,
              tilt: tilt,
            )
        )
    );

    cameraPosition = new LatLng(currentLocation.latitude,currentLocation.longitude);
  }

  void search() {
    String radius = "";
    String filter = "";
    double meters = 1609.34;

    filter = widget.keyword.split(" ")[0];
    radius = widget.keyword.split(" ")[1];

    if(radius == "0")
      meters = meters*5;
    if(radius == "1")
      meters = meters*10;
    if(radius == "2")
      meters = meters*25;

    if(filter == "Park")
      searchNearbySkateParks(cameraPosition.latitude, cameraPosition.longitude,meters);
    else if(filter == "Street")
      _getSavedSpots(meters);
    else if(filter == "All") {
      searchNearbySkateParks(cameraPosition.latitude, cameraPosition.longitude,meters);
      _getSavedSpots(meters);
    }
    else
      print("ERROR SEARCHING.");
  }

  // change icon
  void searchNearbySkateParks(double latitude, double longitude, double radius) async {

    setState(() {
      markers.clear();
    });
    String url =
        '$baseUrl?key=$_API_KEY&location=$latitude,$longitude&radius=$radius&keyword=skatepark';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _handleResponse(data);
    } else {
      throw Exception('An error occurred getting places nearby');
    }

    // make sure to hide searching
    setState(() {
      searching = false;
    });
  }

  void _handleResponse(data){
    // bad api key or otherwise
    if (data['status'] == "REQUEST_DENIED") {
      setState(() {
        error = Error.fromJson(data);
      });
      // success
    }
    else if (data['status'] == "OK") {
      setState(() {
        places = PlaceResponse.parseResults(data['results']);
        for (int i = 0; i < places.length; i++) {
          markers.add(
            Marker(
              markerId: MarkerId(places[i].placeId),
              position: LatLng(places[i].geometry.location.lat,
                  places[i].geometry.location.long),
              infoWindow: InfoWindow(
                  title: places[i].name, snippet: places[i].vicinity),
              onTap: () {},
            ),
          );
        }
      });
    } else {
      print(data);
    }
  }

  void showMenu() {
    showModalBottomSheet(
      elevation: 100,
        context: context,
        builder: (BuildContext context) {
          return new Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              color: Color(0xff232f34),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  height: 50,
                ),
                SizedBox(
                    height: (56 * 6).toDouble(),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                          color: Color(0xff344955),
                        ),
                        child: Stack(
                          alignment: Alignment(0, 0),
                          overflow: Overflow.visible,
                          children: <Widget>[
                            Positioned(
                              child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  ListTile(
                                    title: Text(
                                      "Inbox",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    leading: Icon(
                                      Icons.inbox,
                                      color: Colors.white,
                                    ),
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            )
                          ],
                        ))),
              ],
            ),
          );
        });
  }

}
