import 'package:ep_feedmill/res/string.dart';
import 'package:flutter/material.dart';

mixin SimpleAlertDialogMixin<T extends StatefulWidget> on State<T> {
  void onDialogMessage(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleAlertDialog(
            title: title,
            message: message,
          );
        });
  }
}

class SimpleAlertDialog extends StatelessWidget {
  final String title, message, btnText;

  SimpleAlertDialog({
    @required this.title,
    @required this.message,
    this.btnText: Strings.close,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text(btnText.toUpperCase()),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
