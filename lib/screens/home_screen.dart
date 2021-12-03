import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_unite/models/const.dart';
import 'package:lets_unite/screens/post_main.dart';
import 'package:lets_unite/services/database.dart';
import 'package:lets_unite/services/google_signup.dart';
import 'package:lets_unite/services/sharedprefs.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends StatefulWidget {


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin{
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController mapController;
  late Position currentPosition;
  var geolocator = Geolocator();

  late final MyProfileData myData;
  late final ValueChanged<MyProfileData> updateMyData;


  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: latLngPosition, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(37.4219983, -122.084),
    zoom: 14.4746,
  );

  double bottomPaddingMap = 0;
  final LatLng _center = const LatLng(37.4219983, -122.084);
  int _currentIndex = 3;
  String appBarTitle="Lets Unite";
  final _user = FirebaseAuth.instance.currentUser!;
  Stream<QuerySnapshot> usersStream = new Stream.empty();

  bool _isLoading = false;
   @override
  void initState() {
    appBarTitle="Lets Unite";
    getUserDetails();
    _takeMyData();
    super.initState();
  }

  Future<void> _takeMyData() async{
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String myThumbnail = SharedPreferenceHelper().getUserProfileUrl() as String;
    String myName = SharedPreferenceHelper().getUserDisplayName() as String;

    setState(() {
      myData = MyProfileData(
        myThumbnail: myThumbnail,
        myName: myName,
        myLikeList: prefs.getStringList('likeList')!,
        myLikeCommentList: prefs.getStringList('likeCommentList')!,
        myFCMToken: prefs.getString('FCMToken')!,
      );
    });

    setState(() {
      _isLoading = false;
    });
  }

  void getUserDetails() async {
    usersStream = await DatabaseMethods().getAllUserDetails();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  

  String setTitle(String _title) {
     setState(() {
       appBarTitle = _title;
     });
     return appBarTitle;
  }

  void updatesMyData(MyProfileData newMyData) {
     setState(() {
       myData = newMyData;
     });
  }

  List<Marker> _markersList = [];
  var usersLocations = [];
  getUsersLocation() {
     FirebaseFirestore.instance.collection('posts').get().then((docs) {
       if(docs.docs.isNotEmpty) {
         for(int i=0; i<docs.docs.length; i++) {
           usersLocations.add(docs.docs[i].data);
           // initMarker(docs.docs[i].data);
           // getMarkersList();
           _markersList.add(
               Marker(
                   markerId: MarkerId(i.toString()),
                   position: LatLng(13.0129293, 80.2361008),
                   onTap: null,
                   infoWindow: InfoWindow(
                       title: 'TREE PLANTING',
                       snippet: '10AM to 12PM'
                   ),
                   icon: BitmapDescriptor.defaultMarker
               )
           );
         }
       }
     });
  }

  getMarkersList() {
    _markersList.add(
        Marker(
          markerId: MarkerId('1'),
          position: LatLng(13.0129293, 80.2361008),
          onTap: null,
          infoWindow: InfoWindow(
            title: 'TREE PLANTING',
            snippet: '10AM to 12PM'
          ),
          icon: BitmapDescriptor.defaultMarker
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(setTitle('Lets Unite')),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.settings))
        ],
      ),
      body: _tabsBody(),
      // Stack(
      //   children: [
      //     GoogleMap(
      //       onMapCreated: _onMapCreated,
      //       initialCameraPosition: CameraPosition(
      //         target: _center,
      //         zoom: 11.0,
      //       ),
      //     ),
      //   ],
      // ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        iconSize: 30,
        backgroundColor: Colors.indigo,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
            label: 'Home'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_sharp),
            label: 'Friends'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.post_add_outlined),
            label: 'Posts'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profile'
          )
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  void_onMapCreated(controller) async {
    setState(() {
      mapController = controller;
    });
  }

  _tabsBody() {
    var res;
      if(_currentIndex == 0) {
        setState(() {
          appBarTitle = "Lets Unite";
        });
          res = GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            // onMapCreated: _onMapCreated,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController  controller) {
              _controllerGoogleMap.complete(controller);
              mapController = controller;
              setState(() {
                // bottomPaddingMap = 265.0;
              });
              locatePosition();
            },
            markers: _markersList.toSet(),
            // initialCameraPosition: CameraPosition(
            //   target: _center,
            //   zoom: 11.0,
            // ),
          );
      }
      else if(_currentIndex == 1){
        setState(() {
          appBarTitle = "Users";
        });
        res = Container(
          padding: EdgeInsets.all(20),
          child: Center(
              child: Column(
                  children: [
                    Text('Nearby Users',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),),
                    getUsersList(),
              ])),
        );
      }
      else if(_currentIndex == 2) {
        setState(() {
          appBarTitle = "Posts";
        });
        res = PostMain();
            // PostMain(myData: myData, updateMyData: updateMyData);
      }
      else if(_currentIndex == 3) {
        setState(() {
          appBarTitle = "Profile";
        });
        res = Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigoAccent, Colors.indigoAccent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.5, 0.9],
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.indigo,
                    minRadius: 35.0,
                    child: Icon(
                      Icons.call,
                      size: 30.0,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white70,
                    minRadius: 60.0,
                    child: CircleAvatar(
                      radius: 50.0,
                      backgroundImage: NetworkImage(_user.photoURL!),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.indigo,
                    minRadius: 35.0,
                    child: Icon(
                      Icons.message,
                      size: 30.0,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 7,
              ),
              Text(_user.displayName.toString(),
                style: TextStyle(
                fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
              ),),
              SizedBox(
                height: 15,
              ),
              Container(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('3',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),),
                      Icon(
                        Icons.star,
                        size: 30,
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ),
                ),
              SizedBox(height: 20,),
              ElevatedButton(onPressed: (){
                final provider = Provider.of<GoogleSignInProvider>(context,
                listen: false);
                provider.logout();
              },
                  child: Text('Sign Out'))
            ],
          ),
        );
      }

    return res;
  }

  Widget getUsersList() {
     return StreamBuilder<QuerySnapshot>(
       stream: usersStream,
         builder: (context, snapshot) {
           return snapshot.hasData
               ? ListView.builder(
             itemCount: snapshot.data!.docs.length,
               itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data!.docs[index];
                return createUserListWidget(
                  profileUrl: ds["imageUrl"],
                  name: ds["name"],
                  username: ds["username"]
                );
               },
               shrinkWrap: true,
           )
               : Center(
             child: CircularProgressIndicator(),
           );
         }
     );
  }

  Widget createUserListWidget({required String profileUrl, name, username}) {
     return GestureDetector(
       onTap: null,
       child: Row(
         children: [
           ClipRRect(
             borderRadius: BorderRadius.circular(40),
             child: Image.network(
               profileUrl,
               height: 40,
               width: 40,
             ),
           ),
           SizedBox(width: 12),
           Column(
             children: [
               Text(username),
               Text(name),
               SizedBox(height: 15)
             ],
           )
         ],
       ),
     );
  }

  // Widget _buildBottomBar() {
  //   return CustomAnimatedBottomBar(
  //     containerHeight: 70,
  //   );
  // }
  // https://medium.com/flutterdevs/custom-animated-bottomnavigation-bar-in-flutter-65293e231e4a
  // https://github.com/hello-paulvin/flutter-tutorial-showcase/blob/display-user-on-map-from-api/lib/services/user_api.dart
}
