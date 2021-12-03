import 'package:flutter/material.dart';
import 'package:lets_unite/screens/loc_pick.dart';
import 'package:lets_unite/screens/location_main.dart';
import 'package:lets_unite/services/sharedprefs.dart';

class PickLocationBox extends StatefulWidget {
  const PickLocationBox({Key? key}) : super(key: key);

  @override
  _PickLocationBoxState createState() => _PickLocationBoxState();
}

class _PickLocationBoxState extends State<PickLocationBox> {
  String pickedLocation = '';

  @override
  void initState() {
    // pickedLocation = SharedPreferenceHelper().getPickedAddress() as String;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          (pickedLocation == '') ?
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PickLocation()));
              },
              child: Container(
                width: 150.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Pick Location',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white
                        ),
                      ),
                      Icon(Icons.location_on_outlined)
                    ],),
              ),

            )
          : showPickedLocationTextBox()
        ],
      ),
    );
  }

  Widget showPickedLocationTextBox() {
    setState(() {
      // pickedLocation = SharedPreferenceHelper().getPickedAddress() as String;
    });
    return Text('Event Location: \n $pickedLocation');

  }
}
