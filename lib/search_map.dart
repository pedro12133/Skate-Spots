import 'dart:async';
import 'dart:convert';
import 'data/error.dart';
import 'data/place_response.dart';
import 'data/result.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchMap extends StatefulWidget {
  final String keyword;
  SearchMap(this.keyword);

  @override
  State<SearchMap> createState() {
    return _SearchMap();
  }
}

class _SearchMap extends State<SearchMap> {
  static const String _API_KEY = 'AIzaSyDpxqrntzfSpz89uDHpcdFLPQnmYzrC6NY';
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

  setMarkers() {
    return markers;
  }

  @override
  void initState(){
    super.initState();
    markers.add(Marker(
      markerId: MarkerId(''),
      draggable: true,

      onTap: () {
        print('Marker Tapped');
      },
      position: LatLng(lat,lon),
    ));
  }


  static final CameraPosition _myLocation = CameraPosition(
      target: LatLng(34.0551, -117.7500),
      zoom: zoom,
      bearing: 0.0,
      tilt: tilt,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
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
        onPressed: () {
          _panToCurrentLocation(_mapController);
          print("prev: "+lat.toString()+lon.toString());
          setCameraToCurrentLocation(lat,lon);
          print("current: "+lat.toString()+lon.toString());
          searchNearby(lat, lon);
        },
        backgroundColor: Colors.grey,
        child: Image.asset("assets/images/skate.png"),
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:  BottomAppBar(
        color: Colors.blueGrey,
        shape: CircularNotchedRectangle(),
        notchMargin: 2.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          height: 56.0,
          child: Row(children: <Widget>[
            IconButton(
              onPressed: _getSavedSpots,
              icon: Icon(Icons.list),
              color: Colors.white,
            ),
            Spacer(),
            IconButton(
              onPressed: _saveSpot,
              icon: Icon(Icons.add_location),
              color: Colors.white,
            )
          ]),
        ),
      ),
    );
  }

  void _getSavedSpots() {
    databaseRef.collection('markers')
      .getDocuments().then((QuerySnapshot snapshot) {
        snapshot.documents.forEach((f) => print('${f.data}'));
    });
  }
  void _saveSpot() async {
    print('saving...');
    await databaseRef.collection('markers')
        .add({
          'category' : 'rail',
          'coordinates': new GeoPoint(20, 12),
          'place' : 'Hollywood 8'
        });
    print('Saved!.');
  }
  void addMarker() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    setState(() {
      final marker = Marker(
        markerId: MarkerId(locationCount.toString()),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: 'Location '+locationCount.toString()),
      );
      markers.add(marker);
      print("count: "+markers.length.toString());
      locationCount++;

    });
  }

  void setCameraToCurrentLocation(double lat,double lon) async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    lat = currentLocation.latitude;
    lon = currentLocation.longitude;
    print("inner: "+lat.toString()+lon.toString());

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
  }

  void _setStyle(GoogleMapController controller) async {
    String value = await DefaultAssetBundle.of(context).loadString('assets/maps_style.json');
    controller.setMapStyle(value);
  }

  void searchNearby(double latitude, double longitude) async {
    setState(() {
      markers.clear();
    });
    String url =
        '$baseUrl?key=$_API_KEY&location=$latitude,$longitude&radius=10000&keyword=skatepark';
    print(url);
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
    } else if (data['status'] == "OK") {
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

  showMenu() {
    showModalBottomSheet(
      elevation: 100,
        context: context,
        builder: (BuildContext context) {
          return Container(
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
