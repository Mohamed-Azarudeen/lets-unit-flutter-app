import 'package:flutter/material.dart';
import 'package:lets_unite/services/sharedprefs.dart';

class LocationPickNotifier extends ChangeNotifier {
  String pickedAddress = 'empty';
  double pickedLatitude = 0.0;
  double pickedLongitude = 0.0;


  set address(String address) {
    pickedAddress = address;
    notifyListeners();
  }

  String get _pickedAddress => pickedAddress;
  double get _pickedLatitude => pickedLatitude;
  double get _pickedLongitude => pickedLongitude;

  void locationNotify() {
    try {
      pickedAddress = SharedPreferenceHelper().getPickedAddress() as String;
      pickedLatitude = SharedPreferenceHelper().getPickedLatitude() as double;
      pickedLongitude = SharedPreferenceHelper().getPickedLongitude() as double;
    } catch(e) {
      print('Location Notifier error!!! $e');
    }
    notifyListeners();
  }

}