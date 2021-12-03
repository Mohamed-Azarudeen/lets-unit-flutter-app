import 'package:flutter/material.dart';

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      fillColor: Colors.blue,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.black),
      focusedBorder:
      UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
      enabledBorder:
      UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)));
}