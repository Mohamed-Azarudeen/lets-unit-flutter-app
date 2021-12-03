class MyProfileData {
  final String myThumbnail;
  final String myName;
  final List<String> myLikeList;
  final List<String> myLikeCommentList;
  final String myFCMToken;
  MyProfileData({required this.myThumbnail, required this.myName, required this.myLikeList, required this.myLikeCommentList, required this.myFCMToken});
}

const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

const reportMessage = 'Thank you for reporting. We will determine the user\'s information within 24 hours and delete the account or take action to stop it.';