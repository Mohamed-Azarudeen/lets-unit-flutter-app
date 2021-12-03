import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lets_unite/services/database.dart';
import 'package:lets_unite/services/sharedprefs.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  late final double lat, lng;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if(googleUser == null )
        return ;
      _user = googleUser;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential result = await FirebaseAuth.instance.signInWithCredential(credential);
      User? userDetails = result.user;
      if(result != null) {
        SharedPreferenceHelper().saveUserEmail(userDetails!.email.toString());
        SharedPreferenceHelper().saveUserId(userDetails.uid);
        SharedPreferenceHelper().saveUserName(userDetails.email!.replaceAll("@gmail.com", ""));
        SharedPreferenceHelper().saveUserDisplayName(userDetails.displayName.toString());
        SharedPreferenceHelper().saveUserprofileUrl(userDetails.photoURL.toString());
      }
      locatePosition();
      Map<String, dynamic> userInfoMap = {
        "email": userDetails!.email,
        "username": userDetails.email!.replaceAll("@gmail.com", ""),
        "name": userDetails.displayName,
        "imageUrl": userDetails.photoURL,
        "stars": 0,
        "longitude": lng,
        "latitude": lat,
      };

      DatabaseMethods().adduserInfoToDB(userDetails.uid, userInfoMap);

    } catch(e) {
      print(e.toString());
    }
    notifyListeners();
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    lat = position.latitude;
    lng = position.longitude;
  }

  Future logout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}