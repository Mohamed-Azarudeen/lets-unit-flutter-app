// import 'dart:convert';
// import 'package:lets_unite/models/const.dart';
// import 'package:http/http.dart' as http;
//
// class UserApi {
//   static UserApi _instance;
//
//   UserApi._();
//
//   static UserApi get instance {
//     if (_instance == null) {
//       _instance = UserApi._();
//     }
//     return _instance;
//   }
//
//   Future<List<User>> getAllUser() async {
//     final getUser =
//     await http.get("http://jsonplaceholder.typicode.com/users", headers: {
//       'Content-type': 'application/json',
//       'Accept': 'application/json',
//     });
//     final List responseBody = jsonDecode(getUser.body);
//     return responseBody.map((e) => User.fromJson(e)).toList();
//   }
// }