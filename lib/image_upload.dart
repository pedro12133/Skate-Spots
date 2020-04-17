import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';

import 'loading.dart';

class UploadImage extends StatefulWidget {
  final String from;
  final String to;
  final int amount;

  UploadImage({this.from,this.to,this.amount});

  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {

  double screenHeight;
  double screenWidth;
  Color buttonColor = Colors.blueGrey;
  Color cardIconColor = Colors.blueGrey;
  Color cardColor = Colors.grey[300];
  String uid;
  String folder;
  int amount = 1;
  bool loading = false;
  Widget card = Padding(padding: EdgeInsets.all(0),);
  File _image;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height-100;
    screenWidth = MediaQuery.of(context).size.width;
    uid = widget.from;
    folder = widget.to;
    amount = widget.amount;

    return Scaffold(
      body: !loading ?
      getBodyContainer()
          :
      Stack(
        children: <Widget>[
          getBodyContainer(),
          Loading()
        ],
      )
    );
  }

  Container getBodyContainer() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Colors.white,Colors.blueGrey[700]]
        ),
      ),
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    child: Text('Upload Image',
                      style: GoogleFonts.oleoScript(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                        decoration: TextDecoration.underline,
                      ), // Font
                    ),
                    onHorizontalDragEnd: (detail) => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Container(
              width: screenWidth,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Spacer(),
                    _image == null ?
                        IconButton(
                          icon: Icon(
                            Icons.add_photo_alternate,
                            color: Colors.white,
                          ),
                          onPressed: getImage,
                        )
                        :
                        Spacer(),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              width: MediaQuery.of(context).size.width - 20,
              height: screenHeight/2,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _image != null ?
                  Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Card(
                        elevation: 10,
                        color: cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Image.file(
                                  _image,
                                  height: 300,
                                ),
                                IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () => setState(() => _image = null),
                                )
                              ]
                          ),
                        ),
                      )
                    )
                      :
                    Row()
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(10),),
            _image != null ?
            FloatingActionButton.extended(
              heroTag: "upload",
              backgroundColor: buttonColor,
              onPressed: () => uploadFile(_image),
              label: Text("Upload"),
              icon: Icon(Icons.file_upload),
            )
                :
            Row(),
          ],
        ),
      ),
    );
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> uploadFile(File image) async {
    setState(() => loading = true);
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('$folder/$uid');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;
    storageReference.getDownloadURL().then((fileURL) async {
      await Firestore.instance.collection('users').document(uid).updateData({
        'img' : fileURL,
      }).then((onValue) => setState(() => loading = false)
      ).then((onValue) => Navigator.pop(context));
    });



  }

}
