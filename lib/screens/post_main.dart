import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lets_unite/models/const.dart';
import 'package:lets_unite/models/content_details.dart';
import 'package:lets_unite/models/utils.dart';
import 'package:lets_unite/screens/create_post.dart';
import 'package:lets_unite/screens/post_item.dart';
import 'package:lets_unite/screens/post_items.dart';
import 'package:lets_unite/services/database.dart';

class PostMain extends StatefulWidget {
  // final MyProfileData myData;
  // final ValueChanged<MyProfileData> updateMyData;
  // PostMain({required this.myData, required this.updateMyData});

  @override
  _PostMainState createState() => _PostMainState();
}

class _PostMainState extends State<PostMain> {
  bool _isLoading = false;
  Stream<QuerySnapshot> postsStream = new Stream.empty();

  @override
  void initState() {
    getPostDetails();
    super.initState();
  }

  void getPostDetails() async {
    postsStream = await DatabaseMethods().getAllPosts();
  }

  void _createPost() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePost()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: postsStream,
          builder: (context,snapshot) {
            if (!snapshot.hasData) return LinearProgressIndicator();
            else return Stack(
              children: <Widget>[
                snapshot.data!.docs.length > 0 ?
                ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map((DocumentSnapshot data){
                    return PostItem(data: data, isFromThread:true, parentContext: context);
                      // PostItem(data: data,myData: widget.myData,updateMyDataToMain: widget.updateMyData,postItemAction: _moveToContentDetail,isFromPost:true,commentCount: data['postCommentCount'],parentContext: context,);
                  }).toList(),
                ) :
                Container(
                  child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.error,color: Colors.grey[700],
                            size: 64,),
                          Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Text('There is no post',
                              style: TextStyle(fontSize: 16,color: Colors.grey[700]),
                              textAlign: TextAlign.center,),
                          ),
                        ],
                      )
                  ),
                ),
                Utils.loadingCircle(_isLoading),
              ],
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPost,
        tooltip: 'Increment',
        child: Icon(Icons.create),
      ),
    );
  }

  void _moveToContentDetail(DocumentSnapshot data) {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ContentDetail(postData: data,myData: widget.myData,updateMyData: widget.updateMyData,)));
  }

}
