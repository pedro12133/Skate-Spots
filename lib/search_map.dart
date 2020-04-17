
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skate_maps/popup_alert.dart';
import 'package:skate_maps/set_marker_attributes_form.dart';
import 'package:skate_maps/skate_spot_info_page.dart';
import 'package:skate_maps/user.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong/latlong.dart' as LatLong;


class SearchMap extends StatefulWidget {
  Function setMarkerEditSignInStatus;
  final List<String> keywords;
  final double radius;
  final bool isSignedIn;
  SearchMap(this.keywords,this.radius,this.isSignedIn,this.setMarkerEditSignInStatus);

  @override
  State<SearchMap> createState() {
    return _SearchMap();
  }
}

class _SearchMap extends State<SearchMap> {

  final databaseRef = Firestore.instance;
  List<Marker> markers = [];
  bool editingMarker = false;
  GeoPoint editMarkerPosition;
  GoogleMapController _mapController;
  LatLng cameraPosition;
  static double tilt = 75;
  static double zoom = 12;
  Error error;
  String uid = "";
  double screenHeight;
  double screenWidth;
  List<Padding> infoCards = [];
  List<SkateSpot> skateSpots = [];
  Color cardColor = Colors.grey[200];
  bool listIsOpen = false;
  Color primary = Colors.blueGrey;
  bool rateToggled = false;
  List<Widget> rateButtons = [];
  int rating = -1;
  double animationLength = 100;
  bool animationIsPlaying = false;

  static final CameraPosition _myLocation = CameraPosition(
      target: LatLng(34.0551, -117.7500),
      zoom: zoom,
      bearing: 0.0,
      tilt: tilt,
  );


  @override
  void initState(){
    super.initState();
  }


  @override
  Widget build(BuildContext context) {


    screenHeight = MediaQuery.of(context).size.height-100;
    screenWidth = MediaQuery.of(context).size.width;

    var user = Provider.of<User>(this.context);
    if(user != null)
      uid = user.uid;
    else
      uid = "";


    return Scaffold(
      body: Stack(
          children: <Widget>[
            getMap(),
            infoCards.length > 0 ? getListContainer() : Row(),
          ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 12,
        onPressed: () async {
          if(!editingMarker) {
            _search();
          }
          else {
            _panToCurrentMarkerLocation();
            showAlert('Attributes for current marker aren\'t set.');
          }
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.blueGrey[100]),
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.white70,Colors.blueGrey[900]]
              )
          ),
            child: Image.asset("assets/images/skate.png"),
        ),
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:  BottomAppBar(
        elevation: 10,
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
                    if(listIsOpen)
                      setState(() {
                        infoCards.clear();
                        listIsOpen = false;
                      });
                    else
                      setInfoCards();
                  }
                  else{
                    _panToCurrentMarkerLocation();
                    showAlert("Attributes for current marker aren\'t set.");
                  }
                },
                icon: Icon(Icons.list),
                color: Colors.white,
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  if(widget.isSignedIn) {
                    if(!editingMarker)
                      _addMarker();
                    else {
                      _panToCurrentMarkerLocation();
                      showAlert("Attributes for current marker aren\'t set.");
                    }
                  }
                  else
                    showAlert("You need to sign in to use this feature.");
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

  GoogleMap getMap() {
    return GoogleMap(
      onTap: (val) {
        clearMarkers();
        editingMarker = false;
        widget.setMarkerEditSignInStatus(editingMarker);
      },
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
    );
  }

  Padding getListContainer() {
    FontWeight bold = FontWeight.bold;
    return Padding(
      padding: EdgeInsets.symmetric(vertical:screenWidth/8,horizontal:screenWidth/16),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text("Bank",style: TextStyle(fontWeight: bold),),
                  Icon(Icons.location_on, color: Colors.red,),
                ],
              ),
              Column(
                children: <Widget>[
                  Text("Gap",style: TextStyle(fontWeight: bold),),
                  Icon(Icons.location_on, color: Colors.orange,),
                ],
              ),
              Column(
                children: <Widget>[
                  Text("Hill",style: TextStyle(fontWeight: bold),),
                  Icon(Icons.location_on, color: Colors.yellow[600],),
                ],
              ),
              Column(
                children: <Widget>[
                  Text("Ledge",style: TextStyle(fontWeight: bold),),
                  Icon(Icons.location_on, color: Colors.green,),
                ],
              ),
              Column(
                children: <Widget>[
                  Text("Rail",style: TextStyle(fontWeight: bold),),
                  Icon(Icons.location_on, color: Colors.blue[400],),
                ],
              ),
              Column(
                children: <Widget>[
                  Text("Stairs",style: TextStyle(fontWeight: bold),),
                  Icon(Icons.location_on, color: Colors.blue[800],),
                ],
              ),
              Column(
                children: <Widget>[
                  Text("Other",style: TextStyle(fontWeight: bold),),
                  Icon(Icons.location_on, color: Colors.purple,),
                ],
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: screenHeight/4.5,
            child:
            ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(vertical:5,horizontal: 5),
              itemCount: infoCards.length,
              itemBuilder: (context, index) {return infoCards[index];},
            ),
          ),
        ],
      ),
    );
  }
  
  void setInfoCards() {
    setState(() {
      infoCards.clear();
      for(SkateSpot skateSpot in skateSpots) {
        listIsOpen = true;
        List<Widget> icons = [];
        for(Icon icon in skateSpot.coloredIcons)
          icons.add(
              Padding(
                padding: EdgeInsets.all(1),
                child: icon,
              )
          );
        infoCards.add(
          Padding(
            padding: const EdgeInsets.all(2),
            child: GestureDetector(
              onTap: (){
                //zoom into marker
                _mapController.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                      zoom: 15,
                      tilt: tilt,
                      target: LatLng(
                          markers[skateSpot.index].position.latitude+0.005,
                          markers[skateSpot.index].position.longitude
                      ),
                    )
                ));
                _mapController.showMarkerInfoWindow(markers[skateSpot.index].markerId);
              },
              onLongPress: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SkateSpotInfo(skateSpot)
                    )
                );
              },
              child: Card(
                elevation: 10,
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(3),
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
      }
    });
  }

  // camera methods
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
  
  void _setCameraSearchZoom(double zoom) {
    _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: zoom,
              tilt: tilt,
              target: LatLng(cameraPosition.latitude, cameraPosition.longitude),
            )
        )
    );
  }

  void _panToCurrentMarkerLocation() {
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
  }

  // search methods
  Future _getSavedSpots(List<String> filters, double radius) async {

    LatLong.LatLng userLatLng = new LatLong.LatLng(cameraPosition.latitude, cameraPosition.longitude);
    final LatLong.Distance distance = new LatLong.Distance();

    BitmapDescriptor pinLocationIcon;
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 1), 'assets/images/marker.png')
      .then((icon) {
        setState(() {
          pinLocationIcon = icon;
        });
    });

    int index = -1;
    await databaseRef
        .collection('markers')
        .getDocuments()
        .then((snapshot) {
        for(var x in snapshot.documents) {
          LatLong.LatLng markerLatLng = new LatLong.LatLng(x['lat'], x['lon']);
          double meters = distance(userLatLng, markerLatLng);

        bool containsKeyword = false;
        for(int i = 0; i < filters.length; i++)
          if(x['category'].toString().contains(filters[i]))
            containsKeyword = true;

        if(meters <= radius && containsKeyword) {
          setState(() {
            index++;
            skateSpots.add(
                new SkateSpot(x.documentID,index,x['name'],(meters/1609.34),x['desc'], x['category'],x['lat'],x['lon'])
            );
            final marker = Marker(
              icon: pinLocationIcon,
              markerId: MarkerId(index.toString()),
              position: LatLng(x['lat'], x['lon']),
              infoWindow: InfoWindow(
                  title: x['name'],
              ),
            );
            markers.add(marker);
          });
        }
      }
    });
  }

  void _addMarker() async {

    clearMarkers();

    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    GeoPoint coordinates = new GeoPoint(
        currentLocation.latitude,
        currentLocation.longitude
    );
    editMarkerPosition = new GeoPoint(cameraPosition.latitude, cameraPosition.longitude);
    editingMarker = true;
    widget.setMarkerEditSignInStatus(true);

    BitmapDescriptor pinLocationIcon;
    await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 1), 'assets/images/editMarker.png')
        .then((icon) {
      setState(() {
        pinLocationIcon = icon;
      });
    });

    setState(() {
       Marker marker = Marker(
        icon: pinLocationIcon,
        draggable: true,
        onDragEnd: (value) {
          coordinates = new GeoPoint(value.latitude, value.longitude);
          editMarkerPosition = coordinates;
        },
        markerId: MarkerId("temp"),
        position: LatLng(cameraPosition.latitude, cameraPosition.longitude),
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AttributesForm(
                    from: uid,
                    lat: editMarkerPosition.latitude,
                    lon: editMarkerPosition.longitude,
                  )
              )
          );
          setState(() {
            editingMarker = false;
            widget.setMarkerEditSignInStatus(false);
            markers.clear();
          });

          },
      );
      markers.add(marker);
    });
  }

  void _search() async {
    clearMarkers();

    double radius = widget.radius;
    List filter = widget.keywords;
    double meters = 1609.34;
    double zoom = 0;
    final double currentZoom = await _mapController.getZoomLevel();

   if(filter.length == 0)
     showAlert("Please select search filters.");
   else {
     meters = meters * radius;
     if(radius == 5 && currentZoom > 11.5)
       zoom = 11.5;
     else if(radius == 10 && currentZoom > 10.5)
       zoom = 10.5;
     else if(radius == 25 && currentZoom > 9.5)
       zoom = 9.5;
     else
       zoom = currentZoom;
     _setCameraSearchZoom(zoom);

     await _getSavedSpots(filter,meters);
     setInfoCards();

     if(markers.length < 1) {
       Scaffold.of(context).showSnackBar(new SnackBar(content: Text("No skate spots found here.")));
     }
   }
  }

  void showAlert(String text) {
    showDialog(
        context: context,
        builder: (context) {
          return PopupAlert(text);
        }
    );
  }

  void clearMarkers() {
    setState(() {
      markers.clear();
      infoCards.clear();
      skateSpots.clear();
      listIsOpen = false;
    });
  }

}

class SkateSpot {
  String id = "";
  int index;
  String name = "";
  double distance;
  String description = "";
  String categories = "";
  List<Icon> coloredIcons = [];
  List<String> imageURLs;
  double lat = 0;
  double lon = 0;

  Map<String,Color> iconColorMap = {
    "Bank":Colors.red,
    "Gap":Colors.orange,
    "Hill":Colors.yellow[600],
    "Ledge":Colors.green,
    "Rail":Colors.blue[400],
    "Stairs":Colors.blue[800],
    "Other":Colors.purple
  };

  SkateSpot(id,index,name,distance,description,categories,lat,lon) {
    this.id = id;
    this.index = index;
    this.distance = distance;
    this.name = name;
    this.description = description;
    this.categories = categories;
    this.lat = lat;
    this.lon = lon;

    List cats = categories.toString().split(' ');
    for(int i = 0; i < cats.length-1; i++)
      coloredIcons.add(Icon(Icons.location_on,color: iconColorMap[cats[i]]));
    getImageURLs();
  }

  Future<void> getImageURLs() async {
    await Firestore.instance.collection('markers').document(id).get().then((snap){
      imageURLs = List.from(snap.data['imgLinks']);
    });
  }

}

