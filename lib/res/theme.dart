import 'package:flutter/material.dart';

ThemeData appTheme(BuildContext context) => ThemeData(
    primaryColor: Colors.blue[700],
    primaryColorDark: Colors.blue[900],
    accentColor: Colors.orange[900],
    primarySwatch: Colors.blue,
    highlightColor: Colors.blue[50],
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
    ));
