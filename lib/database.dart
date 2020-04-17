import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skate_maps/search_map.dart';
import 'package:latlong/latlong.dart' as LatLong;

class DatabaseService {

  final String uid;
  DatabaseService({this.uid});

  // collection references
  final CollectionReference markersCollection = Firestore.instance.collection('markers');
  final CollectionReference usersCollection = Firestore.instance.collection('users');
  final StorageReference markerImagesReference = FirebaseStorage.instance.ref().child('marker_images');



  Future setUserData(String fname, String lname, String email, int spots,) async {
    return await usersCollection.document(uid).setData({
      'fname' : fname,
      'lname' : lname,
      'email' : email,
      'favoriteSpots' : <String>[],
      'mySpots' : <String>[],
    });
  }



  Future updateUserMarkers(String markerId) async {

    List<String> mySpots = [];
    try{
      // get current fav marker ids from user database
      await usersCollection.document(uid).get().then((snap) {
        mySpots = List.from(snap.data['mySpots']);
      }).catchError((onError) => {});

      if(!mySpots.contains(markerId)) {
        // add new favorite marker to list
        mySpots.add(markerId);

        // post new favs list
        await usersCollection.document(uid).updateData({
          'mySpots':mySpots,
        });
      }
      else
        print("Already added");

    }
    catch(e) {
      print(e.toString());
    }


  }

  Future updateUserFavoriteMarkers(String markerId) async {
    List<String> favoriteSpots = [];
    try{
      // get current fav marker ids from user database
      await usersCollection.document(uid).get().then((snap) {
        favoriteSpots = List.from(snap.data['favoriteSpots']);
      }).catchError((onError) => {});

      if(!favoriteSpots.contains(markerId)) {
        // add new favorite marker to list
        favoriteSpots.add(markerId);
      }
      else {
        // remove this spot from list
        favoriteSpots.remove(markerId);
      }
      // post new favs list
      await usersCollection.document(uid).updateData({
        'favoriteSpots':favoriteSpots,
      });
    }
    catch(e) {
      print(e.toString());
    }

  }



  Future addMarker(String category, double lat, double lon, String name,String description) async {
    return await Firestore.instance.collection('markers')
        .add({
      'category' : category,
      'creator' : uid,
      'lat': lat,
      'lon': lon,
      'name' : name,
      'desc' : description,
      'imgLinks': <String>[],
    });

  }

  Future updateMarkerImages(String markerId,List<File> images) async {

    List<String> imgLinks = [];
    StorageReference markerFolder = markerImagesReference.child(markerId);

    try{
      // get current image links from marker database
      await markersCollection.document(markerId).get().then((snap) {
          imgLinks = List.from(snap.data['imgLinks']);
      });

      // upload new images to storage and get new image links
      int count = imgLinks.length;
      for(File image in images) {
        StorageUploadTask uploadTask = markerFolder.child('$count').putFile(
            image);
        await uploadTask.onComplete;
        await markerFolder.child('$count').getDownloadURL().then((fileURL) =>
            imgLinks.add(fileURL));
        count++;
      }

      // update image links in marker database
      await markersCollection.document(markerId).updateData({
        'imgLinks':imgLinks,
      });
    }
    catch(e) {
      print("ERROR adding images");
    }
  }

  Future getMarkerImageLinks(String markerId) async {
    await markersCollection.document(markerId).get().then((snap) {
      return List.from(snap.data['imgLinks']);
    });
  }

  // get user stream
  Stream<QuerySnapshot> get users {
    return usersCollection.snapshots();
  }

  Future<SkateSpot> getMarkerById(String id, int index) async {
    String name = "";
    String description = "";
    String categories;
    double lat = 0;
    double lon = 0;

    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    LatLong.Distance distance = new LatLong.Distance();

    double meters = 0;

    await markersCollection.document(id).get().then((onValue) {
      name = onValue.data['name'];
      description = onValue.data['desc'];
      categories = onValue.data['category'];
      lat = onValue.data['lat'];
      lon = onValue.data['lon'];
      meters = distance(
          LatLong.LatLng(currentLocation.latitude,currentLocation.longitude),
          LatLong.LatLng(lat,lon)
          );
    });

    return new SkateSpot(id, index, name, meters/1609.34, description, categories,lat,lon);
  }
}