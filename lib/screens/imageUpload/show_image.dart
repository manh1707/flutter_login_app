import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class ShowImage extends StatefulWidget {
  String? userId;
  ShowImage({Key? key, this.userId}) : super(key: key);

  @override
  _ShowImageState createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your image'),
      ),
      body: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text("data no have"),
            );
          } else {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  String url = snapshot.data!.docs[index]['downloadURL'];

                  return Container(
                    child: Column(
                      children: [
                        Image.network(
                          url,
                          fit: BoxFit.cover,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              deleteData();
                            },
                            child: Text('delete'))
                      ],
                    ),
                  );
                });
          }
        },
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('images')
            .snapshots(),
      ),
    );
  }

  deleteData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .collection('images')
        .doc()
        .delete();
  }
}
