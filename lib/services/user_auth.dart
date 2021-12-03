import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_unite/screens/home_screen.dart';
import 'package:lets_unite/screens/login_screen.dart';

class UserAuth extends StatelessWidget {
  const UserAuth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
          } else if(snapshot.hasData) {
            return HomeScreen();
          } else if(snapshot.hasError) {
            return Center(child: Text('Something Went Wrong!!!'));
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
