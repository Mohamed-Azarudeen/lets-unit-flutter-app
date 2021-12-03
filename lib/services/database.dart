import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lets_unite/models/const.dart';
import 'package:lets_unite/models/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseMethods {
  Future adduserInfoToDB(
      String userId, Map<String, dynamic> userInfoMap) async {
   return FirebaseFirestore.instance
       .collection("users")
       .doc(userId)
       .set(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getAllUserDetails() async {
    return FirebaseFirestore.instance
        .collection("users")
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getCurrentUserDetails(String username) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo:  username)
        .snapshots();
  }
  
  Future<Stream<QuerySnapshot>> getAllPosts() async {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('postTimeStamp', descending: true)
        .snapshots();
  }

  static Future<void> updatePostLikeCount(DocumentSnapshot postData,bool isLikePost,MyProfileData myProfileData) async{
    postData.reference.update({'postLikeCount': FieldValue.increment(isLikePost ? -1 : 1)});
    // if(!isLikePost){
    //   await FBCloudMessaging.instance.sendNotificationMessageToPeerUser('${myProfileData.myName} likes your post','${myProfileData.myName}',postData['FCMToken']);
    // }
  }

  static Future<void> updateCommentLikeCount(DocumentSnapshot postData,bool isLikePost,MyProfileData myProfileData) async{
    postData.reference.update({'commentLikeCount': FieldValue.increment(isLikePost ? -1 : 1)});
    if(!isLikePost){
      // await FBCloudMessaging.instance.sendNotificationMessageToPeerUser('${myProfileData.myName} likes your comment','${myProfileData.myName}',postData['FCMToken']);
    }
  }


  static Future<void> likeToPost(String postID,MyProfileData userProfile,bool isLikePost) async{
    if (isLikePost) {
      DocumentReference likeReference = FirebaseFirestore.instance.collection('posts').doc(postID).collection('like').doc(userProfile.myName);
      await FirebaseFirestore.instance.runTransaction((Transaction myTransaction) async {
        await myTransaction.delete(likeReference);
      });
    }else {
      await FirebaseFirestore.instance.collection('post').doc(postID).collection('like').doc(userProfile.myName).set({
        'userName':userProfile.myName,
        // 'userThumbnail':userProfile.myThumbnail,
      });
    }
  }

  static Future<void> commentToPost(String toUserID,String toCommentID,String postID,String commentContent,MyProfileData userProfile,String postFCMToken) async{
    String commentID = Utils.getRandomString(8) + Random().nextInt(500).toString();
    String myFCMToken;
    if(userProfile.myFCMToken == null){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      myFCMToken = prefs.getString('FCMToken')!;
    }else {
      myFCMToken = userProfile.myFCMToken;
    }
    FirebaseFirestore.instance.collection('posts').doc(postID).collection('comment').doc(commentID).set({
      'toUserID':toUserID,
      'commentID':commentID,
      'toCommentID':toCommentID,
      'userName':userProfile.myName,
      // 'userThumbnail':userProfile.myThumbnail,
      'commentTimeStamp':DateTime.now().millisecondsSinceEpoch,
      'commentContent':commentContent,
      'commentLikeCount':0,
      'FCMToken':myFCMToken
    });
    // await FBCloudMessaging.instance.sendNotificationMessageToPeerUser(commentContent,'${userProfile.myName} was commented',postFCMToken);
  }

  static Future<void> updatePostCommentCount(DocumentSnapshot postData,) async{
    postData.reference.update({'postCommentCount': FieldValue.increment(1)});
  }

  static Future<void> sendPostInFirebase(String postID,String postTitle, String postDesc, String userName,String userThumbnail, String postImageURL, String postAddress, double pickedLat, double pickedLng, String pickedDate, String pickedTime) async{
    String postFCMToken;
    // if(userProfile.myFCMToken == null){
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   postFCMToken = prefs.getString('FCMToken')!;
    // }else {
    //   postFCMToken = userProfile.myFCMToken;
    // }
    FirebaseFirestore.instance.collection('posts').doc(postID).set({
      'postID':postID,
      'userName':userName,
      'userThumbnail':userThumbnail,
      'postTimeStamp':DateTime.now().millisecondsSinceEpoch,
      'postTitle':postTitle,
      'postDesc':postDesc,
      'postImage':postImageURL,
      'postLocation': postAddress,
      'postPickedLatitude': pickedLat,
      'postPickedLongitude': pickedLng,
      'postPickedDate': pickedDate,
      'postPickedTime': pickedTime,
      'postLikeCount':0,
      'postVolunteerCount':0,
      // 'FCMToken':postFCMToken
    });
  }

  static Future<String?> uploadPostImages({required String postID, required File postImageFile}) async {
    try {
      String fileName = 'postImages/$postID/postImage';
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = reference.putFile(postImageFile);
      TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() => print('upload completed'));
      String postImageURL = await storageTaskSnapshot.ref.getDownloadURL();
      return postImageURL;
    }catch(e) {
      return null;
    }
  }

}