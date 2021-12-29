import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_unite/models/const.dart';
import 'package:lets_unite/screens/post_main.dart';
import 'package:lets_unite/services/google_signup.dart';
import 'package:lets_unite/services/sharedprefs.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late GoogleMapController mapController;
  late Position currentPosition;
  var geolocator = Geolocator();
  static const _initialCameraPosition =
      CameraPosition(target: LatLng(13.010651, 80.2331943), zoom: 10);
  late GoogleMapController _googleMapController;
  late Position? initPos = getPosition();
  late Position? markerPos;


  late final MyProfileData myData;
  late final ValueChanged<MyProfileData> updateMyData;

  Future<Position> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getPosition() {
    getUserLocation().then((value) {
      print('Map Co-ordinates');
      print(value);
      setState(() {
        initPos = value;
      });
      initPos = value;
      print('init Position');
      print(initPos);
      // getAddress(value);
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  double bottomPaddingMap = 0;
  final LatLng _center = const LatLng(37.4219983, -122.084);
  int _currentIndex = 1;
  String appBarTitle = "Lets Unite";
  final _user = FirebaseAuth.instance.currentUser!;
  Stream<QuerySnapshot> usersStream = new Stream.empty();
  Stream<QuerySnapshot> postsStream = new Stream.empty();

  bool _isLoading = false;

  @override
  void initState() {
    appBarTitle = "Lets Unite";
    locatePosition();
    _takeMyData();
    super.initState();
  }

  Future<void> _takeMyData() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(setTitle('Lets Unite')),
        actions: [
          IconButton(onPressed: () {
            final provider =
            Provider.of<GoogleSignInProvider>(context, listen: false);
            provider.logout();
          }, icon: Icon(Icons.logout))],
      ),
      body: _tabsBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        iconSize: 30,
        backgroundColor: Colors.indigo,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Profile')
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
    if (_currentIndex == 0) {
      setTitle('Posts Feed');
      final geo = Geoflutterfire();
      GeoFirePoint center = geo.point(latitude: currentPosition.latitude, longitude: currentPosition.longitude);
      final _firestore = FirebaseFirestore.instance;
      var collectionReference = _firestore.collection('posts');
      double radius = 4;
      String field = 'position';

      Stream<List<DocumentSnapshot>> postsStream = geo.collection(collectionRef: collectionReference)
          .within(center: center, radius: radius, field: field);

      res = StreamBuilder<List<DocumentSnapshot>>(
        stream: postsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.active) {
            Set<Marker> _markersList =  snapshot.data!.map((e) => Marker(
              markerId: MarkerId("1"),
              infoWindow: InfoWindow(title: e['postTitle']),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              position: LatLng(e['postPickedLatitude'],e['postPickedLongitude']),
            )).toSet();

            return GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onMapCreated: (controller) => _googleMapController = controller,
              markers: _markersList,
              onTap: (address) {
                print(address);
              },
            );
          }
          else
            return Center(child: CircularProgressIndicator());
        },
      );
    } else if (_currentIndex == 1) {
      setState(() {
        appBarTitle = "Posts Feeds";
      });
      res = PostMain();
      // PostMain(myData: myData, updateMyData: updateMyData);
    } else if (_currentIndex == 2) {
      setTitle('Profile');
      res =
          Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [Colors.indigoAccent, Colors.indigoAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.5, 0.9],
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  child: CircleAvatar(
                    backgroundColor: Colors.indigo,
                    minRadius: 35.0,
                    child: Icon(
                      Icons.post_add_sharp,
                      size: 30.0,
                    ),
                  ),
                  // onTap: _myPosts,
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
            Text(
              _user.displayName.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '3',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Icon(
                      Icons.star,
                      size: 30,
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    }

    return res;
  }

  // Widget _buildBottomBar() {
  //   return CustomAnimatedBottomBar(
  //     containerHeight: 70,
  //   );
  // }
  // https://medium.com/flutterdevs/custom-animated-bottomnavigation-bar-in-flutter-65293e231e4a
  // https://github.com/hello-paulvin/flutter-tutorial-showcase/blob/display-user-on-map-from-api/lib/services/user_api.dart
}
