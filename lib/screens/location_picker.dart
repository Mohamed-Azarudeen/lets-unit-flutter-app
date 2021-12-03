import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_unite/services/sharedprefs.dart';

class LocationPicker extends StatefulWidget {

  final LatLng markerLocation;
  final LatLng userLocation;
  final onTap;


  LocationPicker({this.onTap, required this.markerLocation, required this.userLocation});
  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  String pickedAddress = '';
  late double lat;
  late double lon;
  late double pickedLat;
  late double pickedLng;

  List<Marker> _marker = [];

  @override
  void initState() {

    super.initState();
  }

  Future<dynamic> getSetAddress() async {
    lat = widget.markerLocation == null
        ? widget.userLocation.latitude
        : widget.markerLocation.latitude;
    lon = widget.markerLocation == null
        ? widget.userLocation.longitude
        : widget.markerLocation.longitude;
    final addresses = await Geocoder.local
        .findAddressesFromCoordinates(Coordinates(lat, lon));
    return pickedAddress = addresses.first.addressLine;
  }


  @override
  Widget build(BuildContext context) {
    lat = widget.markerLocation == null
        ? widget.userLocation.latitude
        : widget.markerLocation.latitude;
    lon = widget.markerLocation == null
        ? widget.userLocation.longitude
        : widget.markerLocation.longitude;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GoogleMap(
                myLocationEnabled: true,
                onTap: widget.onTap,
                compassEnabled: true,
                initialCameraPosition: CameraPosition(
                    target: widget.userLocation ?? LatLng(11.1271, 78.6569),
                    zoom: 15),
                mapType: MapType.normal,
                markers: [
                  Marker(
                  markerId: MarkerId('Id'),
                  position: LatLng(widget.markerLocation.latitude, widget.markerLocation.longitude)
                  )
                ].toSet(),//_marker.toSet(),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FutureBuilder<dynamic>(
                      future: getSetAddress(),
                      builder: (context, snapshot) {
                        switch (snapshot.hasData) {
                          case true:
                            return Text(
                              'Address :\n$pickedAddress',
                              style: TextStyle(color: Colors.red),
                            );
                          default:
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                        }
                      }),
                  SizedBox(
                    height: 10,
                  ),
                  FlatButton(
                    onPressed: () {
                      print('picker');
                      SharedPreferenceHelper().savePickedAddress(pickedAddress);
                      var temp = SharedPreferenceHelper().getPickedAddress();
                      print(temp);
                      try {
                        Navigator.pop(context);
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Text('CONFIRM LOCATION'),
                    color: Colors.indigo,
                    textColor: Colors.white,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double getPickedLocationLatitude() {
    return lat;
  }
  double getPickedLocationLongitude() {
    return lon;
  }
  String getPickedLocationAddress() {
    return pickedAddress;
  }
}
