import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  GoogleMapController mapController;
  GoogleMap map;
  AppBar appBar;
  Row controlButtons;
  List<Marker> _markers = <Marker>[];
  int locationCount = 0;
  LatLng center = const LatLng(34.0551, -117.7500);
  


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void zoomIn() {
    mapController.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    mapController.animateCamera(CameraUpdate.zoomOut());
  }

  void panToCurrentLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    mapController.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(currentLocation.latitude,currentLocation.longitude),
              zoom: 13,
            )
        )
    );
  }

  Row createZoomButtons() {

    double iconSize = 40;
    Icon plus = Icon(OMIcons.zoomIn, size: iconSize);
    Icon minus = Icon(OMIcons.zoomOut, size: iconSize);
    Icon addMarker = Icon(OMIcons.addLocation, size: iconSize);

    controlButtons = Row(

      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              FlatButton(
                onPressed: zoomIn,
                child: plus,
              ),
              FlatButton(
                onPressed: null,
              ),
              FlatButton(
                onPressed: zoomOut,
                child: minus
              ),
              FlatButton(
                onPressed: null,
              ),
              FlatButton(
                onPressed: addLocation,
                child: addMarker,
              ),
            ]
        ),
      ],
    );
  return controlButtons;
  }
  
  GoogleMap createMap() {
    map = GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: 11.0,
      ),
      markers: Set<Marker>.of(_markers),
      myLocationEnabled: true,

    );
    return map;
  }

  void addLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    setState(() {
      final marker = Marker(
        markerId: MarkerId(locationCount.toString()),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: 'Location '+locationCount.toString()),
      );
      _markers.add(marker);
      print("count: "+_markers.length.toString());
      locationCount++;

    });
  }

  AppBar createAppBar() {
    appBar = AppBar(
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
        child: Text('SkateMaps',
          style: GoogleFonts.rockSalt(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            shadows:
            [Shadow(color: Colors.black,offset: Offset(-2.5, -2.5))],
          ), // Font
        ),
      ),
    );
    return appBar;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: createAppBar(),
        body: Stack(
          children: <Widget>[
            createMap(),
            createZoomButtons(),
          ],
        ),
      ),
    );
  }

}
