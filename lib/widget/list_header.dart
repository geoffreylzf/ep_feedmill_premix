import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListHeader extends StatelessWidget {
  final String text;

  ListHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey
      ),
    );
  }
}
