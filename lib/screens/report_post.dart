import 'package:flutter/material.dart';

class ReportPost extends StatefulWidget {
  const ReportPost({Key? key}) : super(key: key);

  @override
  _ReportPostState createState() => _ReportPostState();
}

class _ReportPostState extends State<ReportPost> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text('Report Post'),
    );
  }
}
