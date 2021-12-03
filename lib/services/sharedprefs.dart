import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static String userIdKey = "USERKEY";
  static String userNamekey = "USERNAMEKEY";
  static String displayName = "USERDISPLAYNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userProfileKey = "USERPROFILEKEY";
  static String userProfilePicKey = "USERPROFILEPICKEY";

  Future<bool> saveUserEmail(String getUserEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, getUserEmail);
  }
  Future<bool> saveUserId(String getUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getUserId);
  }
  Future<bool> saveUserDisplayName(String getDisplayName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userProfileKey, getDisplayName);
  }
  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNamekey, getUserName);
  }
  Future<bool> saveUserprofileUrl(String getUserProfile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userProfilePicKey, getUserProfile);
  }
  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }
  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }
  Future<String?> getUserDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userProfileKey);
  }
  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNamekey);
  }
  Future<String?> getUserProfileUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userProfilePicKey);
  }

  static Future<List<String>> saveLikeList(String postID,List<String> myLikeList,bool isLikePost,String updateType) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> newLikeList = myLikeList;
    if(myLikeList == null) {
      newLikeList = <String>[];
      newLikeList.add(postID);
    }else {
      if (isLikePost) {
        myLikeList.remove(postID);
      }else {
        myLikeList.add(postID);
      }
    }
    prefs.setStringList(updateType, newLikeList);
    return newLikeList;
  }

  void savePickedAddress(String address) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('pickedAddress', address);
  }

  Future<String?> getPickedAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('pickedAddress');
  }

  void savePickedLatitude(double lat) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('pickedLatitude', lat);
  }

  Future<double?> getPickedLatitude() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('pickedLatitude');
  }

  void savePickedLongitude(double lng) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('pickedLongitude', lng);
  }

  Future<double?> getPickedLongitude() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('pickedLongitude');
  }

}