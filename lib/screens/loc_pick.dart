import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_unite/screens/create_post.dart';

class PickLocation extends StatefulWidget {
  const PickLocation({Key? key}) : super(key: key);

  @override
  _PickLocationState createState() => _PickLocationState();
}


class _PickLocationState extends State<PickLocation> {
  static const _initialCameraPosition =
  CameraPosition(target: LatLng(13.010651, 80.2331943), zoom: 17);

  late String? markerAddress = '';
  late double pickedLatitude;
  late double pickedLongitude;
  late GoogleMapController _googleMapController;
  late Position? initPos = getPosition();
  late Position? markerPos;

  late Marker _userLocation = Marker(
    markerId: MarkerId("User's Home"),
    infoWindow: InfoWindow(title: 'Home'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    position: LatLng(initPos != null ? initPos?.latitude as double : 13.010651,
        initPos != null ? initPos?.longitude as double : 80.2331943),
  );

  Future<Position> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getAddress(Position value) async {
    List<Placemark> placemarks = (await placemarkFromCoordinates(
      value.latitude,
      value.longitude,
    ));

    markerAddress = placemarks[0].name! +
        ' ,' +
        placemarks[0].street! +
        ' ,' +
        placemarks[0].thoroughfare! +
        ' ,' +
        placemarks[0].subLocality! +
        ' ,' +
        placemarks[0].locality! +
        '-' +
        placemarks[0].postalCode! +
        ' ,' +
        placemarks[0].isoCountryCode!;
    print(placemarks[0]);
  }

  getMarkerAddress(LatLng value) async {
    List<Placemark> placemarks = (await placemarkFromCoordinates(
      value.latitude,
      value.longitude,
    ));
    setState(() {
      pickedLatitude = value.latitude;
      pickedLongitude = value.longitude;
    });
    print(placemarks);
    markerAddress = placemarks[0].name! +
        ' ,' +
        placemarks[0].street! +
        ' ,' +
        placemarks[0].thoroughfare! +
        ' ,' +
        placemarks[0].subLocality! +
        ' ,' +
        placemarks[0].locality! +
        '-' +
        placemarks[0].postalCode! +
        ' ,' +
        placemarks[0].isoCountryCode!;

    print(markerAddress);
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
      getAddress(value);
    });
  }

  @override
  void initState() {
    super.initState();
    getPosition();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void _addMarker(LatLng pos) async {
      setState(() {
        _userLocation = Marker(
          markerId: MarkerId("UserId"),
          infoWindow: InfoWindow(title: 'Id'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
        );
        getMarkerAddress(pos);
      });
    }

    if (initPos == Null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
            value: 5,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Pick Event location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              _userLocation,
            },
            onTap: (address) {
              print('long pressed');
              print(address);
              _addMarker(address);
            },
          ),
          Positioned(
            bottom: 2,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePost(address: markerAddress!, latitude: pickedLatitude, longitude: pickedLongitude)));
                    // Navigator.pop(context);
                  },
                  child: Text(
                    "Confirm Location",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Text(
                    'Address: $markerAddress',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? getMarkedAddress() {
    return markerAddress!;
  }

}