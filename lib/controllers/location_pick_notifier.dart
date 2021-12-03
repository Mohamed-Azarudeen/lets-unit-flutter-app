import 'package:flutter/material.dart';

class LocationPickNotifier extends ChangeNotifier {
  String pickedAddress;
  // double pickedLatitude;
  // double pickedLongitude;
  LocationPickNotifier(this.pickedAddress);

  set value(String address) {
    pickedAddress = address;
    notifyListeners();
  }

  String get value => pickedAddress;

}