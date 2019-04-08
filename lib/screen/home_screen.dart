import 'package:ep_feedmill/res/nav.dart';
import 'package:ep_feedmill/res/route.dart';
import 'package:ep_feedmill/res/string.dart';
import 'package:ep_feedmill/screen/print_preview_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.appName)),
      body: _Dashboard(),
      drawer: NavDrawerStart(),
    );
  }
}

class _Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: _LogCard(),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
            child: _PremixCard(),
          ),
        ),
      ],
    );
  }
}

class _LogCard extends StatelessWidget {
  @override
  Card build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: RaisedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PrintPreviewScreen(
                      "123456789", "ABCDEFGHOHYEAHasas\n\n\n\n")));
            },
            child: const Text("Print Preview")),
      ),
    );
  }
}

class _PremixCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text("Delivery Order",
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.assignment,
                  size: 40,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(Strings.document),
                ),
              ],
            ),
          ),
          RaisedButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.premix);
            },
            child: Text(Strings.premix.toUpperCase()),
          )
        ],
      ),
    ));
  }
}
