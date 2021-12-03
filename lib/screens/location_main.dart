import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_unite/screens/location_picker.dart';
import 'package:lets_unite/services/sharedprefs.dart';
import 'package:location/location.dart';

class LocationMain extends StatefulWidget {

  @override
  _LocationMainState createState() => _LocationMainState();
}

class _LocationMainState extends State<LocationMain> {

  LatLng _markerLocation = LatLng(12.9908, 80.2421);
  late LatLng _userLocation;
  Location location = new Location();
  late Future<LocationData> _getUserLocation;

  Future<LocationData> getUserLocation() async {

    final result = await location.getLocation();
    double? lat = result.latitude;
    double? lng = result.longitude;
    print(lat);
    print("\n");
    print(lng);
    _userLocation = LatLng(lat!, lng!);
    _markerLocation = _userLocation;
    return result;
  }

  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    _userLocation = LatLng(position.latitude, position.longitude);
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation = getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationData>(
      future: _getUserLocation,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return LocationPicker(
            onTap: (location) async {
              setState((){
                _markerLocation = location;
                SharedPreferenceHelper().savePickedLatitude(_markerLocation.latitude);
                SharedPreferenceHelper().savePickedLongitude(_markerLocation.longitude);
              });
            },
            markerLocation: _markerLocation,
            userLocation: _userLocation,
          );
        }
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
              value: 5,
            ),
          ),
        );
      },
    );
  }

}
