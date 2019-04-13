import 'package:ep_feedmill/animation/slide_right_route.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/print_preview/print_preview_screen.dart';
import 'package:flutter/material.dart';

class Save extends StatefulWidget {
  @override
  _SaveState createState() => _SaveState();
}

class _SaveState extends State<Save> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton.icon(
        icon: Icon(Icons.save),
        onPressed: () {


        },
        label: Text(
          Strings.save.toUpperCase(),
        ),
      ),
    );
  }

  goPrintPreview(BuildContext ctx) {
    Navigator.of(ctx).pushReplacement(
      SlideRightRoute(
        widget: PrintPreviewScreen(
          printText: "BLABLABLA",
          qrText: "TUTUTUTUT",
        ),
      ),
    );
  }
}
