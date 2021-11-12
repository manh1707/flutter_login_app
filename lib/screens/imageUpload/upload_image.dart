import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ImageUpload extends StatefulWidget {
  String? userId;
  ImageUpload({Key? key, this.userId}) : super(key: key);

  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  File? _image;
  final imagePicker = ImagePicker();
  String? dowloadURl;

  Future imagePickerMethod() async {
    final pick = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pick != null) {
        _image = File(pick.path);
      } else {
        showSnackBar("no file selected", Duration(milliseconds: 300));
      }
    });
  }

  Future uploadImage() async {
    final postID = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${widget.userId}image/images")
        .child('post_$postID');
    await ref.putFile(_image!);
    dowloadURl = await ref.getDownloadURL();
    await firebaseFirestore
        .collection('users')
        .doc(widget.userId)
        .collection("images")
        .doc('post_$postID')
        .set({'downloadURL': dowloadURl}).whenComplete(
            () => showSnackBar('Upload succeed', Duration(milliseconds: 300)));
    Navigator.of(context).pop();
  }

  showSnackBar(String text, Duration d) {
    final SnackText = SnackBar(
      content: Text(text),
      duration: d,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              height: 500,
              width: double.infinity,
              child: Column(
                children: [
                  const Text('Upload image'),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      flex: 4,
                      child: Container(
                        width: 350,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue)),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: _image == null
                                      ? const Center(
                                          child: Text('No image selected'),
                                        )
                                      : Image.file(_image!)),
                              ElevatedButton(
                                  onPressed: () {
                                    imagePickerMethod();
                                  },
                                  child: Text('Select image')),
                              ElevatedButton(
                                  onPressed: () {
                                    if (_image != null) {
                                      uploadImage();
                                    } else {
                                      showSnackBar("No image selected",
                                          Duration(milliseconds: 300));
                                    }
                                  },
                                  child: Text('Up load image')),
                            ],
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
