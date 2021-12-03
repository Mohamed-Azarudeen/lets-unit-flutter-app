import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:lets_unite/models/utils.dart';
import 'package:lets_unite/screens/loc_pick.dart';
import 'package:lets_unite/services/database.dart';

class CreatePost extends StatefulWidget with ChangeNotifier{
  // final MyProfileData myData;
  // CreatePost({required this.myData});
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {

  TextEditingController titleTextController = TextEditingController();
  TextEditingController descTextController = TextEditingController();
  final FocusNode _nodeText1 = FocusNode();
  FocusNode titleTextFocus = FocusNode();
  FocusNode descTextFocus = FocusNode();
  bool _isLoading = false;
  final _user = FirebaseAuth.instance.currentUser!;
  File? _postImageFile;
  String pickedAddress = '';
  late DateTime pickedDate;
  late TimeOfDay pickedTime;
  late double _pickedLatitude;
  late double _pickedLongitude;

  @override
  void initState() {
    super.initState();
    pickedDate = DateTime.now();
    pickedTime = TimeOfDay.now();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
            displayArrows: false,
            focusNode: _nodeText1
        ),
      ]
    );
  }
  
  void _postToDB() async {
    setState(() {
      _isLoading = true;
    });
    String postID = Utils.getRandomString(8) + Random().nextInt(500).toString();
    String postImageURL;
    if(_postImageFile != null) {
      postImageURL = (await DatabaseMethods.uploadPostImages(postID: postID, postImageFile: _postImageFile as File))!.toString();
      DatabaseMethods.sendPostInFirebase(postID, titleTextController.text, descTextController.text, _user.displayName.toString(), _user.photoURL.toString(), postImageURL, pickedAddress, _pickedLatitude, _pickedLongitude, pickedDate.toString(), pickedTime.toString());
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        actions: [
          FlatButton(
              onPressed: _postToDB,
              child: Text('Post',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
              )
          )
        ],
      ),
      body: Stack(
        children: [
          KeyboardActions(
              config: _buildConfig(context),
            child: Column(
              children: [
                Container(
                  width: size.width,
                  height: size.height - MediaQuery.of(context).viewInsets.bottom - 80,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14.0, left: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white70,
                                  minRadius: 30.0,
                                  // child: Image.asset(_user.photoURL.toString()),
                                  child: CircleAvatar(
                                    radius: 20.0,
                                    backgroundImage: NetworkImage(_user.photoURL!),
                                  ),
                                ),
                                Text(_user.displayName.toString(),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold
                                    )
                                )
                              ],
                            ),
                            Divider(height: 1, color: Colors.black,),
                            Container(
                              child: Column(
                                children: [
                                  TextFormField(
                                    focusNode: titleTextFocus,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Event Title',
                                      hintMaxLines: 2,
                                    ),
                                    controller: titleTextController,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                  ),
                                  TextFormField(
                                    focusNode: descTextFocus,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Description',
                                      hintMaxLines: 4,
                                    ),
                                    controller: descTextController,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                  ),
                                ],
                              ),
                            ),
                            pickedDate != null && pickedTime != null?
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ListTile(
                                  title: Text("Event Date: ${pickedDate.year}, ${pickedDate.month}, ${pickedDate.day}"),
                                  trailing: Icon(Icons.date_range_sharp, color: Colors.indigo),
                                  onTap: _pickDate,
                                ),
                                ListTile(
                                  title: Text("Event Time: ${pickedTime.hour}:${pickedTime.minute}"),
                                  trailing: Icon(Icons.lock_clock, color: Colors.indigo),
                                  onTap: _pickTime,
                                ),
                                ListTile(
                                  title: Text("Event Location: $pickedAddress"),
                                  trailing: Icon(Icons.location_on, color: Colors.indigo,),
                                  onTap: _pickLocation,
                                ),
                                ListTile(
                                  title: Text("Image: "),
                                  trailing: Icon(Icons.add_photo_alternate, color: Colors.indigo,),
                                  onTap: _getImageAndCrop,
                                ),
                              ],
                            )
                                : Column(
                              children: [
                                Text('Event Date: $pickedDate'),
                                Text('Event Date: $pickedTime')
                            ],)
                            ,
                            _postImageFile != null ? Image.file(_postImageFile!, fit: BoxFit.fill,) : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Utils.loadingCircle(_isLoading),
  ],
      ),
    );
  }

  Future<void> _getImageAndCrop() async {

    try {
      final imageFileFromGallery = await ImagePicker().pickImage(source: ImageSource.gallery);

      if(imageFileFromGallery == null) return;
      final img = File(imageFileFromGallery.path);
      setState(() {
        _postImageFile = img;
      });
    } on PlatformException catch(e) {
      print('Failed to pick image: $e');
    }
  }

  _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year-5),
      lastDate: DateTime(DateTime.now().year+5),
      initialDate: pickedDate,
    );
    if(date != null)
      setState(() {
        pickedDate = date;
      });
  }

  _pickTime() async {
    TimeOfDay? t = await showTimePicker(
        context: context,
        initialTime: pickedTime
    );
    if(t != null)
      setState(() {
        pickedTime = t;
      });
  }

  _pickLocation() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PickLocation()));
      if(pickedAddress != null) {
        setState(() {
          pickedAddress = markerAddress!;
          _pickedLatitude = pickedLatitude;
          _pickedLongitude = pickedLongitude;
        });
      }
  }

}
