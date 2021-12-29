import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lets_unite/screens/loc_pick.dart';
import 'package:lets_unite/screens/post_item.dart';

class PostMain extends StatefulWidget {

  @override
  _PostMainState createState() => _PostMainState();
}

class _PostMainState extends State<PostMain> {

  void _createPost() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PickLocation()));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Position>(
        future:  Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high),
        builder: (context, snapshot){
          if(snapshot.hasData) {
            final geo = Geoflutterfire();
            GeoFirePoint center = geo.point(latitude: snapshot.data!.latitude, longitude: snapshot.data!.longitude);
            final _firestore = FirebaseFirestore.instance;
            var collectionReference = _firestore.collection('posts');
            double radius = 4;
            String field = 'position';

            Stream<List<DocumentSnapshot>> postsStream = geo.collection(collectionRef: collectionReference)
                .within(center: center, radius: radius, field: field);

            return StreamBuilder<List<DocumentSnapshot>>(
                stream: postsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.active) {
                    return Stack(
                      children: <Widget>[
                        snapshot.data!.length > 0 ?
                        ListView(
                          shrinkWrap: true,
                          children: snapshot.data!.map((DocumentSnapshot data) {
                            return PostItem(data: data,
                                isFromThread: true,
                                parentContext: context);
                            // PostItem(data: data,myData: widget.myData,updateMyDataToMain: widget.updateMyData,postItemAction: _moveToContentDetail,isFromPost:true,commentCount: data['postCommentCount'],parentContext: context,);
                          }).toList(),
                        ) :
                        Container(
                          child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.error, color: Colors.grey[700],
                                    size: 64,),
                                  Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Text('There is no post',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700]),
                                      textAlign: TextAlign.center,),
                                  ),
                                ],
                              )
                          ),
                        ),
                        // Utils.loadingCircle(_isLoading),
                      ],
                    );
                  }
                  return LinearProgressIndicator();
                }
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPost,
        tooltip: 'Increment',
        child: Icon(Icons.post_add_outlined, size: 35,),
      ),
    );
  }

  void _moveToContentDetail(DocumentSnapshot data) {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ContentDetail(postData: data,myData: widget.myData,updateMyData: widget.updateMyData,)));
  }

}
