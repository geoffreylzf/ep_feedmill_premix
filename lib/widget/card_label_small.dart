import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CardLabelSmall extends StatelessWidget {
  final String text;

  CardLabelSmall(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
