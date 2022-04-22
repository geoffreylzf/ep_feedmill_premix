import 'package:flutter/material.dart';

class PlanBarcodeDialog extends StatelessWidget {
  final _scanController = TextEditingController();
  final void Function(String) callback;

  PlanBarcodeDialog({
    @required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Scan Tag Barcode"),
      content: TextField(
        keyboardType: TextInputType.text,
        controller: _scanController,
        autofocus: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(12.0),
          border: OutlineInputBorder(),
          labelText: "Barcode",
        ),
        onSubmitted: (v) {
          Navigator.of(context).pop();
          callback(v);
        },
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("CANCEL"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("START"),
          onPressed: () {
            Navigator.of(context).pop();
            callback(_scanController.text);
          },
        ),
      ],
    );
  }
}
