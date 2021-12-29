import 'package:flutter/material.dart';
import 'package:lets_unite/controllers/location_pick_notifier.dart';
import 'package:lets_unite/screens/home_screen.dart';
import 'package:lets_unite/services/google_signup.dart';
import 'package:lets_unite/services/user_auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => GoogleSignInProvider()),
      ChangeNotifierProvider(create: (context) => LocationPickNotifier()),
      ],
      child: MaterialApp(
        title: 'Lets Unite',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: AnimatedSplashScreen(
          splash: Icons.people,
          splashIconSize: 200.0,
          duration: 1500,
          splashTransition: SplashTransition.fadeTransition,
          backgroundColor: Colors.indigo,
          nextScreen: UserAuth(),
        ),
        routes: {
          '/home': (BuildContext context) => new HomeScreen(),
        },
      )
  );
}

