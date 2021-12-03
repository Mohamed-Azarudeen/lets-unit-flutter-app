import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lets_unite/models/const.dart';
import 'package:lets_unite/models/utils.dart';

import 'report_post.dart';

class PostItems extends StatefulWidget {
  late final DocumentSnapshot data;
  late final BuildContext parentContext;
  late final MyProfileData myData;
  late final ValueChanged<MyProfileData> updateMyDataToMain;
  late final bool isFromPost;
  late final  Function postItemAction;
  late final int commentCount;

  // PostItem({required this.data, required this.myData, required this.updateMyDataToMain, required this.postItemAction, required this.isFromPost, required this.commentCount, required this.parentContext});

  @override
  _PostItemsState createState() => _PostItemsState();
}

class _PostItemsState extends State<PostItems> {
  late MyProfileData _currentMyData;
  late int _likeCount;

  @override
  void initState() {
    _currentMyData = widget.myData;
    _likeCount = widget.data['postLikeCount'];
    super.initState();
  }

  // void _updateLikeCount(bool isLikePost) async{
  //   MyProfileData _newProfileData = await Utils.updateLikeCount(widget.data,widget.myData.myLikeList != null && widget.myData.myLikeList.contains(widget.data['postID']) ? true : false,widget.myData,widget.updateMyDataToMain,true);
  //   setState(() {
  //     _currentMyData = _newProfileData;
  //   });
  //   setState(() {
  //     isLikePost ? _likeCount-- : _likeCount++;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 6.0),
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: (){},
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6.0, 2.0, 10.0, 2.0),
                    child: Container(
                      width: 48,
                      height: 48,
                      child: Text('Image'),
                    ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('username',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),),
                       Padding(
                         padding: const EdgeInsets.all(2.0),
                       child: Text('post timestamp',
                       style: TextStyle(
                         fontSize: 16,
                         color: Colors.black87
                       ),),)
                      ],
                    ),
                    Spacer(),
                    PopupMenuButton<int>(
                        itemBuilder: (context)=>[
                          PopupMenuItem(
                            value: 1,
                              child: Row(
                                children: [
                                  Padding(padding: const EdgeInsets.only(
                                    right: 8.0,
                                    left: 8.0,
                                  ),
                                  child: Icon(Icons.report),),
                                  Text("Report"),
                                ],
                              ))
                        ],
                      initialValue: 1,
                      onCanceled: () {
                          print("You have canceled the menu.");
                      },
                      onSelected: (value){
                          showDialog(
                              context: widget.parentContext,
                              builder: (BuildContext context)=> ReportPost());
                      },
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: ()=> widget.isFromPost? widget.postItemAction(widget.data):null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 4, 10),
                  child: Column(
                    children: [
                      Text((widget.data['postTitle'] as String).length > 200 ? '${widget.data['postTitle'].substring(0, 132)} ...' : widget.data['postTitle'],
                        style: TextStyle(fontSize: 16),
                        maxLines: 3,
                      ),
                      Text((widget.data['postDesc'] as String).length > 200 ? '${widget.data['postDesc'].substring(0, 132)} ...' : widget.data['postDesc'],
                        style: TextStyle(fontSize: 16),
                        maxLines: 3,
                      ),
                    ],
                  )
                ),
              ),
              widget.data['postImage'] != 'NONE' ? GestureDetector(
                onTap: ()=> widget.isFromPost ? widget.postItemAction(widget.data) : widget.postItemAction(),
                child: Utils.cacheNetworkImageWithEvent(context, widget.data['postImage'], 0, 0),
              ) : Container(),
              Divider(height: 2, color: Colors.black,),
              Padding(
                padding: const EdgeInsets.only(top:6.0, bottom: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: null, //() => _updateLikeCount(_currentMyData.myLikeList != null && _currentMyData.myLikeList.contains(widget.data['postID']) ? true : false),
                      child: Row(
                        children: <Widget>[
                          // Icon(Icons.thumb_up,size: 18,color: widget.myData.myLikeList != null && widget.myData.myLikeList.contains(widget.data['postID']) ? Colors.blue[900] : Colors.black),
                          // Padding(
                          //   padding: const EdgeInsets.only(left:8.0),
                          //   child: Text('Like ( ${widget.isFromPost ? widget.data['postLikeCount'] : _likeCount} )',
                          //     style: TextStyle(fontSize: 16,
                          //         fontWeight: FontWeight.bold,
                          //         // color: widget.myData.myLikeList != null && widget.myData.myLikeList.contains(widget.data['postID']) ? Colors.blue[900] : Colors.black),),
                          // ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.isFromPost ? widget.postItemAction(widget.data) : null,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.mode_comment,size: 18),
                          Padding(
                            padding: const EdgeInsets.only(left:8.0),
                            child: Text('Comment ( ${widget.commentCount} )',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
