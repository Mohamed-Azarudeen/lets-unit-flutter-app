import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lets_unite/models/utils.dart';

class PostItem extends StatefulWidget {
  final DocumentSnapshot data;
  final BuildContext parentContext;
  final bool isFromThread;
  PostItem({required this.data, required this.isFromThread, required this.parentContext});

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
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
                onTap: null,
                child: Row(
                  children: [
                    Padding(padding: const EdgeInsets.fromLTRB(6.0,2.0,10.0,2.0),
                      child: Container(
                        width: 48,
                        height: 48,
                        child: CircleAvatar(
                          radius: 20.0,
                          backgroundImage: NetworkImage(widget.data['userThumbnail']),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.data['userName'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(Utils.readTimestamp(widget.data['postTimeStamp']),style: TextStyle(fontSize: 16,color: Colors.black87),),
                        ),
                      ],
                    ),
                    Spacer(),
                    PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right:8.0,left:8.0),
                                child: Icon(Icons.report),
                              ),
                              Text("Report"),
                            ],
                          ),
                        ),
                      ],
                      initialValue: 1,
                      onCanceled: () {
                        print("You have canceled the menu.");
                      },
                      // onSelected: (value) {
                      //   showDialog(
                      //       context: widget.parentContext,
                      //       builder: (BuildContext context) => ReportPost(postUserName: widget.data['userName'],postId:widget.data['postID'],content:widget.data['postContent'],reporter: widget.myData.myName,));
                      // },
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: null,//() => widget.isFromThread ? widget.threadItemAction(widget.data) : null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8,10,4,10),
                  child: Column(
                    children: [
                      Text((widget.data['postTitle'] as String).length > 200 ? '${widget.data['postTitle'].substring(0, 132)} ...' : widget.data['postTitle'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 3,),
                      Text((widget.data['postDesc'] as String).length > 200 ? '${widget.data['postDesc'].substring(0, 132)} ...' : widget.data['postDesc'],
                        style: TextStyle(fontSize: 16,),
                        maxLines: 3,),
                    ],
                  )
                ),
              ),
              widget.data['postImage'] != 'NONE' ? Card(
                elevation: 2.0,
                child: GestureDetector(
                    onTap: null,//() => widget.isFromThread ? widget.threadItemAction(widget.data) : widget.threadItemAction(),
                    child: Utils.cacheNetworkImageWithEvent(context,widget.data['postImage'],0,0)),
              ) :
              Container(),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.indigo,),
                  Expanded(
                    child: Text(widget.data['postLocation'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo
                      ),
                    )
                  ),
                  ]
              ),
              SizedBox(height: 15,),
              Row(
                children: [
                  Icon(Icons.date_range_sharp, color: Colors.indigo,),
                  Text('${widget.data['postPickedDate']}',
                    style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),),
                ],
              ),
              Divider(height: 2,color: Colors.black,),
            ],
          ),
        ),
      ),
    );
  }
}
