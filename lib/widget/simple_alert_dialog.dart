import 'package:flutter/material.dart';

class SimpleAlertDialog extends StatelessWidget {
  final String title, message, btnText;

  SimpleAlertDialog({
    @required this.title,
    @required this.message,
    @required this.btnText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text(btnText),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
